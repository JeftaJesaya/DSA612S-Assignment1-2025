import ballerina/http;
import ballerina/io;

// DATA TYPES 

type Task record {
    int id;
    string description;
    string status; 
};

type WorkOrder record {
    int id;
    string description;
    string status;
    Task[] tasks;
};

type Schedule record {
    int id;
    string description;
    string nextDueDate; 
};

type Component record {
    int id;
    string name;
};

type Asset record { 
    int id;
    string name;
    string faculty;
    string department;
    string status; 
    string acquiredDate; 
    Component[] components;
    Schedule[] schedules;
    WorkOrder[] workOrders;
};

type NewAsset record { 
    string name;
    string faculty;
    string department;
    string status; 
    string acquiredDate;
};

 //IN-MEMORY STORAGE 

Asset[] assets = [];
int nextAssetId = 1;
int nextComponentId = 1;
int nextScheduleId = 1;
int nextWorkOrderId = 1;
int nextTaskId = 1;

 //HTTP LISTENER 

listener http:Listener userListener = new (9090);

// STAFF SERVICE 

service /staff on userListener {

//  ASSET MANAGEMENT 

    resource function post addAsset(NewAsset newAsset) returns Asset {
        Asset asset = {
            id: nextAssetId,
            name: newAsset.name,
            faculty: newAsset.faculty,
            department: newAsset.department,
            status: newAsset.status,
            acquiredDate: newAsset.acquiredDate,
            components: [],
            schedules: [],
            workOrders: []
        };
        nextAssetId += 1;
        assets.push(asset);
        io:println("Server: Added asset -> " + asset.toJsonString());
        return asset;
    }

    resource function get listAssets() returns Asset[] {
        return assets;
    }

    resource function get listByFaculty(string faculty) returns Asset[] {
        Asset[] result = [];
        foreach var a in assets {
            if a.faculty.toLowerAscii() == faculty.toLowerAscii() {
                result.push(a);
            }
        }
        return result;
    }

    resource function put updateAsset(int id, NewAsset updatedAsset) returns Asset|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == id {
                assets[i].name = updatedAsset.name;
                assets[i].faculty = updatedAsset.faculty;
                assets[i].department = updatedAsset.department;
                assets[i].status = updatedAsset.status;
                assets[i].acquiredDate = updatedAsset.acquiredDate;
                return assets[i];
            }
        }
        return error("Asset with ID " + id.toString() + " not found.");
    }

    resource function get lookupAsset(int id) returns Asset|error {
        foreach var a in assets {
            if a.id == id {
                return a;
            }
        }
        return error("Asset with ID " + id.toString() + " not found.");
    }

    resource function delete removeAsset(int id) returns string|error {
        int index = -1;
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == id {
                index = i;
                break;
            }
        }
        if index != -1 {
            _ = assets.remove(index);
            return "Asset removed successfully.";
        } else {
            return error("Asset with ID " + id.toString() + " not found.");
        }
    }

    //  OVERDUE SCHEDULES 

    resource function get overdueItems(string currentDate) returns Asset[]|error {
        Asset[] overdueAssets = [];
        foreach var asset in assets {
            foreach var schedule in asset.schedules {
                if schedule.nextDueDate < currentDate {
                    overdueAssets.push(asset);
                    break; 
                }
            }
        }
        return overdueAssets;
    }

    //  COMPONENTS 

resource function post addComponent(int assetId, Component newComp) returns Component|error {
    foreach int i in 0 ..< assets.length() {
        if assets[i].id == assetId {
            Component comp = { id: nextComponentId, name: newComp.name };
            nextComponentId += 1;
            assets[i].components.push(comp);
            return comp;
        }
    }
    return error("Asset with ID " + assetId.toString() + " not found.");
}


    resource function delete removeComponent(int assetId, int componentId) returns string|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                int index = -1;
                foreach int j in 0 ..< assets[i].components.length() {
                    if assets[i].components[j].id == componentId {
                        index = j;
                        break;
                    }
                }
                if index != -1 {
                    _ = assets[i].components.remove(index);
                    return "Component removed successfully.";
                }
                return error("Component not found.");
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    resource function get listComponents(int assetId) returns Component[]|error {
        foreach var a in assets {
            if a.id == assetId {
                return a.components;
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    //  SCHEDULES 

    resource function post addSchedule(int assetId, Schedule newSchedule) returns Schedule|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                Schedule sched = { id: nextScheduleId, description: newSchedule.description, nextDueDate: newSchedule.nextDueDate };
                nextScheduleId += 1;
                assets[i].schedules.push(sched);
                return sched;
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    resource function delete removeSchedule(int assetId, int scheduleId) returns string|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                int index = -1;
                foreach int j in 0 ..< assets[i].schedules.length() {
                    if assets[i].schedules[j].id == scheduleId {
                        index = j;
                        break;
                    }
                }
                if index != -1 {
                    _ = assets[i].schedules.remove(index);
                    return "Schedule removed successfully.";
                }
                return error("Schedule not found.");
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }
    //  SCHEDULES 

resource function get listSchedules(int assetId) returns Schedule[]|error {
    foreach var a in assets {
        if a.id == assetId {
            return a.schedules;
        }
    }
    return error("Asset with ID " + assetId.toString() + " not found.");
}


    // WORK ORDERS 

    resource function post addWorkOrder(int assetId, WorkOrder newWO) returns WorkOrder|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                WorkOrder wo = { id: nextWorkOrderId, description: newWO.description, status: newWO.status, tasks: [] };
                nextWorkOrderId += 1;
                assets[i].workOrders.push(wo);
                return wo;
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    resource function put updateWorkOrderStatus(int assetId, int workOrderId, string status) returns WorkOrder|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                foreach int j in 0 ..< assets[i].workOrders.length() {
                    if assets[i].workOrders[j].id == workOrderId {
                        assets[i].workOrders[j].status = status;
                        return assets[i].workOrders[j];
                    }
                }
                return error("Work order not found.");
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    //  TASKS 

    resource function post addTask(int assetId, int workOrderId, string description) returns Task|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                foreach int j in 0 ..< assets[i].workOrders.length() {
                    if assets[i].workOrders[j].id == workOrderId {
                        Task task = { id: nextTaskId, description: description, status: "PENDING" };
                        nextTaskId += 1;
                        assets[i].workOrders[j].tasks.push(task);
                        return task;
                    }
                }
                return error("Work order not found.");
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }

    resource function delete removeTask(int assetId, int workOrderId, int taskId) returns string|error {
        foreach int i in 0 ..< assets.length() {
            if assets[i].id == assetId {
                foreach int j in 0 ..< assets[i].workOrders.length() {
                    if assets[i].workOrders[j].id == workOrderId {
                        int index = -1;
                        foreach int k in 0 ..< assets[i].workOrders[j].tasks.length() {
                            if assets[i].workOrders[j].tasks[k].id == taskId {
                                index = k;
                                break;
                            }
                        }
                        if index != -1 {
                            _ = assets[i].workOrders[j].tasks.remove(index);
                            return "Task removed successfully.";
                        }
                        return error("Task not found.");
                    }
                }
                return error("Work order not found.");
            }
        }
        return error("Asset with ID " + assetId.toString() + " not found.");
    }
}

// MAIN

public function main() {
    io:println("Server running on port 9090...");
    io:println("Staff can create/manage assets, components, schedules, work orders, and tasks.");
}
