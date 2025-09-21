import ballerina/http;
import ballerina/io;



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
type NewAsset record { 
    string name;
    string faculty;
    string department;
    string status; 
    string acquiredDate;
};


type Component record {
    int id;
    string name;
};

type Schedule record {
    int id;
    string description;
    string nextDueDate; 
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


// == HTTP CLIENT ==
http:Client staffClient = check new ("http://localhost:9090/staff");

// MENU FUNCTIONS
function showMainMenu() {
    io:println("\n--- Main Menu ---");
    io:println("1. Staff");
    io:println("2. Students (coming soon)");
    io:println("3. Exit");
    io:print("Enter choice: ");
}

function showStaffMenu() {
    io:println("\n--- Staff Menu ---");
    io:println("1. Create and Manage Assets");
    io:println("2. View All Assets");
    io:println("3. View Assets by Faculty");
    io:println("4. Check for Overdue Items");
    io:println("5. Manage Components");
    io:println("6. Schedule Management");
    io:println("7. Work Order Management");
    io:println("8. Back to Staff Login");
    io:print("Enter choice: ");
}

function showAssetsMenu() {
    io:println("\n--- Asset Management ---");
    io:println("1. Add New Asset");
    io:println("2. Update Asset Information");
    io:println("3. Lookup Asset by ID");
    io:println("4. Remove Asset");
    io:println("5. Back to Staff Menu");
    io:print("Enter choice: ");
}

function showComponentsMenu() {
    io:println("\n--- Component Management ---");
    io:println("1. List Components");
    io:println("2. Add Component");
    io:println("3. Remove Component");
    io:println("4. Back to Staff Menu");
    io:print("Enter choice: ");
}
function showTasksMenu() {
    io:println("\n--- Task Management ---");
    io:println("1. Add Task");
    io:println("2. Remove Task");
    io:println("3. Back to Work Orders Menu");
    io:print("Enter choice: ");
}
function showSchedulesMenu() {
    io:println("\n=== Schedule Management ===");
    io:println("1. List all schedules");
    io:println("2. Add a new schedule");
    io:println("3. Remove a schedule");
    io:println("4. Back to previous menu");
    io:print("Enter your choice: ");
}

function showWorkOrdersMenu() {
    io:println("\n--- Work Order Management Menu ---");
    io:println("1. Add Work Order");
    io:println("2. Update Work Order Status");
    io:println("3. Add Task to Work Order");
    io:println("4. Remove Task from Work Order");
    io:println("5. Back to Staff Menu");
    io:print("Enter your choice: ");
}


//  FUNCTIONS 
function addAsset(NewAsset newAsset) returns Asset|error {
    Asset response = check staffClient->post("/addAsset", newAsset);
    return response;
}

function getAllAssets() returns Asset[]|error {
    Asset[] response = check staffClient->get("/listAssets");
    return response;
}

function getAssetsByFaculty(string faculty) returns Asset[]|error {
    string path = string `/listByFaculty?faculty=${faculty}`;
    Asset[] response = check staffClient->get(path);
    return response;
}

function updateAsset(int id, NewAsset updatedAsset) returns Asset|error {
    string path = string `/updateAsset?id=${id}`;
    Asset response = check staffClient->put(path, updatedAsset);
    return response;
}

function getAsset(int id) returns Asset|error {
    string path = string `/lookupAsset?id=${id}`;
    Asset response = check staffClient->get(path);
    return response;
}

function deleteAsset(int id) returns string|error {
    string path = string `/removeAsset?id=${id}`;
    string response = check staffClient->delete(path);
    return response;
}

function checkOverdueItems(string currentDate) returns Asset[]|error {
    string path = string `/overdueItems?currentDate=${currentDate}`;
    Asset[] response = check staffClient->get(path);
    return response;
}

function listComponents(int assetId) returns Component[]|error {
    string path = string `/listComponents?assetId=${assetId}`;
    Component[] response = check staffClient->get(path);
    return response;
}

function addComponent(int assetId, string name) returns Component|error {
    Component comp = { id: 0, name: name };
    string path = string `/addComponent?assetId=${assetId}`;
    Component response = check staffClient->post(path, comp);
    return response;
}


function removeComponent(int assetId, int componentId) returns string|error {
    string path = string `/removeComponent?assetId=${assetId}&componentId=${componentId}`;
    string response = check staffClient->delete(path);
    return response;
}

//  TASK FUNCTIONS


function addTask(int assetId, int workOrderId, string description) returns Task|error {
    
    string path = string `/addTask?assetId=${assetId}&workOrderId=${workOrderId}&description=${description}`;
    Task response = check staffClient->post(path, ());
    return response;
}
function removeTask(int assetId, int workOrderId, int taskId) returns string|error {
    string path = string `/removeTask?assetId=${assetId}&workOrderId=${workOrderId}&taskId=${taskId}`;
    string response = check staffClient->delete(path);
    return response;
}



function addWorkOrder(int assetId, WorkOrder newWO) returns WorkOrder|error {
    string path = string `/addWorkOrder?assetId=${assetId}`;
    WorkOrder response = check staffClient->post(path, newWO);
    return response;
}

// Update status of an existing work order
function updateWorkOrderStatus(int assetId, int workOrderId, string status) returns WorkOrder|error {
    string path = string `/updateWorkOrderStatus?assetId=${assetId}&workOrderId=${workOrderId}`;
    map<string|string[]> payload = { "status": status };
    WorkOrder response = check staffClient->put(path, payload);
    return response;
}

//  SCHEDULES 
function listSchedules(int assetId) returns Schedule[]|error {
    string path = string `/lookupAsset?id=${assetId}`;
    Asset asset = check staffClient->get(path);
    return asset.schedules;
}

function addSchedule(int assetId, string description, string dueDate) returns Schedule|error {
    Schedule sched = { id: 0, description: description, nextDueDate: dueDate };
    string path = string `/addSchedule?assetId=${assetId}`;
    return check staffClient->post(path, sched);
}

function removeSchedule(int assetId, int scheduleId) returns string|error {
    string path = string `/removeSchedule?assetId=${assetId}&scheduleId=${scheduleId}`;
    return check staffClient->delete(path);
}

// MENU HANDLERS
function handleAssets() returns error? {
    while true {
        showAssetsMenu();
        string|error choice = io:readln();
        if choice is error { io:println("Invalid input."); continue; }

        string trimmedChoice = choice.trim();
        if trimmedChoice == "1" {
            io:print("Enter asset name: ");
            string|error name = io:readln();
            io:print("Enter faculty: ");
            string|error faculty = io:readln();
            io:print("Enter department Name: " +"");
            string|error department = io:readln();
            io:print("Enter acquired date (YYYY-MM-DD): ");
            string|error acquiredDate = io:readln();
            io:print("Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
            string|error status = io:readln();


            if name is error || faculty is error || acquiredDate is error || department is error ||  status is error ||
               name.trim().length() == 0 || faculty.trim().length() == 0 || acquiredDate.trim().length() == 0 || department.trim().length() == 0 ||  status.trim().length() == 0{
                io:println("Invalid input."); continue;
            }
            Asset|error added = addAsset({ 
                name: name.trim(), 
                faculty: faculty.trim(), 
                acquiredDate: acquiredDate.trim(),
                department: department.trim(),
                status: status.trim()
            });
            if added is error { io:println("Error adding asset: " + added.message()); }
            else { io:println("Added asset: " + added.toJsonString()); }

        } else if trimmedChoice == "2" {
            io:print("Enter asset ID to update: ");
            string|error idInput = io:readln();
            if idInput is error { io:println("Invalid input."); continue; }
            int|error id = int:fromString(idInput.trim());
            if id is error { io:println("Invalid ID."); continue; }
            io:print("Enter new asset name: ");
            string|error name = io:readln();
            io:print("Enter new faculty: ");
            string|error faculty = io:readln();
             io:print("Enter New department Name: ");
            string|error department = io:readln();
            io:print("Enter new acquired date (YYYY-MM-DD): ");
            string|error acquiredDate = io:readln();
             io:print("New Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
            string|error status = io:readln();
            if name is error || faculty is error || acquiredDate is error || department is error ||status is error ||
               name.trim().length() == 0 || faculty.trim().length() == 0 || acquiredDate.trim().length() == 0 ||department.trim().length() == 0 ||  status.trim().length() == 0 {
                io:println("Invalid input."); continue;
            }
            Asset|error updated = updateAsset(id, { 
                name: name.trim(), 
                faculty: faculty.trim(), 
                acquiredDate: acquiredDate.trim(), 
                department: department.trim(),
                status: status.trim()
            });
            if updated is error { io:println("Error updating asset: " + updated.message()); }
            else { io:println("Updated asset: " + updated.toJsonString()); }

        } else if trimmedChoice == "3" {
            io:print("Enter asset ID to lookup: ");
            string|error idInput = io:readln();
            if idInput is error { io:println("Invalid input."); continue; }
            int|error id = int:fromString(idInput.trim());
            if id is error { io:println("Invalid ID."); continue; }
            Asset|error asset = getAsset(id);
            if asset is error { io:println("Error: " + asset.message()); }
            else { io:println("Found asset: " + asset.toJsonString()); }

        } else if trimmedChoice == "4" {
            io:print("Enter asset ID to delete: ");
            string|error idInput = io:readln();
            if idInput is error { io:println("Invalid input."); continue; }
            int|error id = int:fromString(idInput.trim());
            if id is error { io:println("Invalid ID."); continue; }
            string|error result = deleteAsset(id);
            if result is error { io:println("Error deleting asset: " + result.message()); }
            else { io:println(result); }

        } else if trimmedChoice == "5" {
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
    }
}

function handleComponents() returns error? {
    io:print("Enter Asset ID to manage components: ");
    string|error idInput = io:readln();
    if idInput is error { io:println("Invalid input."); return; }
    int|error assetId = int:fromString(idInput.trim());
    if assetId is error { io:println("Invalid asset ID."); return; }

    while true {
        showComponentsMenu();
        string|error choice = io:readln();
        if choice is error { io:println("Invalid input."); continue; }

        string trimmedChoice = choice.trim();
        if trimmedChoice == "1" {
            Component[]|error comps = listComponents(assetId);
            if comps is error { io:println("Error: " + comps.message()); }
            else if comps.length() == 0 { io:println("No components found."); }
            else {
                io:println("Components:");
                foreach var c in comps {
                    io:println(" - ID: " + c.id.toString() + ", Name: " + c.name);
                }
            }

        } else if trimmedChoice == "2" {
            io:print("Enter component name: ");
            string|error name = io:readln();
            if name is error || name.trim().length() == 0 { io:println("Invalid input."); continue; }
            Component|error comp = addComponent(assetId, name.trim());
            if comp is error { io:println("Error adding component: " + comp.message()); }
            else { io:println("Added component: " + comp.toJsonString()); }

        } else if trimmedChoice == "3" {
            io:print("Enter component ID to remove: ");
            string|error cidInput = io:readln();
            if cidInput is error { io:println("Invalid input."); continue; }
            int|error cid = int:fromString(cidInput.trim());
            if cid is error { io:println("Invalid ID."); continue; }
            string|error result = removeComponent(assetId, cid);
            if result is error { io:println("Error: " + result.message()); }
            else { io:println(result); }

        } else if trimmedChoice == "4" {
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
    }
}

function handleSchedules() returns error? {
    
    io:print("Enter Asset ID to manage schedules: ");
    string|error idInput = io:readln();
    if idInput is error { io:println("Invalid input."); return; }
    int|error assetId = int:fromString(idInput.trim());
    if assetId is error { io:println("Invalid asset ID."); return; }

    while true {
        showSchedulesMenu();
        string|error schedChoiceInput = io:readln();
        if schedChoiceInput is error { 
            io:println("Invalid input."); 
            continue; 
        }
        string schedChoice = schedChoiceInput.trim();

        if schedChoice == "1" {
            Schedule[]|error schedules = listSchedules(assetId);
            if schedules is error {
                io:println("Error: " + schedules.message());
            } else if schedules.length() == 0 {
                io:println("No schedules found for this asset.");
            } else {
                foreach var s in schedules {
                    io:println("Schedule ID: " + s.id.toString() + 
                               " | " + s.description + 
                               " | Next Due: " + s.nextDueDate);
                }
            }

        } else if schedChoice == "2" {
            io:print("Enter schedule description: ");
            string|error descInput = io:readln();
            if descInput is error { io:println("Invalid input."); continue; }

            io:print("Enter next due date (YYYY-MM-DD): ");
            string|error dateInput = io:readln();
            if dateInput is error { io:println("Invalid input."); continue; }

            Schedule|error newSched = addSchedule(assetId, descInput.trim(), dateInput.trim());
            if newSched is error {
                io:println("Error adding schedule: " + newSched.message());
            } else {
                io:println("Added: " + newSched.toJsonString());
            }

        } else if schedChoice == "3" {
            io:print("Enter schedule ID to remove: ");
            string|error schedIdInput = io:readln();
            if schedIdInput is error { io:println("Invalid input."); continue; }
            int|error schedId = int:fromString(schedIdInput.trim());
            if schedId is error { io:println("Invalid ID."); continue; }

            string|error result = removeSchedule(assetId, schedId);
            if result is error {
                io:println("Error: " + result.message());
            } else {
                io:println(result);
            }

        } else if schedChoice == "4" {
            break;

        } else {
            io:println("Invalid option.");
        }
    }
}


function handleStaff() returns error? {
    while true {
        showStaffMenu();
        string|error choice = io:readln();
        if choice is error { io:println("Invalid input."); continue; }

        string trimmedChoice = choice.trim();
        if trimmedChoice == "1" { check handleAssets(); }
        else if trimmedChoice == "2" {
            Asset[]|error assets = getAllAssets();
            if assets is error { io:println("Error retrieving assets: " + assets.message()); }
            else if assets.length() == 0 { io:println("No assets available."); }
            else {
                io:println("All Assets:");
                foreach var a in assets {
                    io:println(" - ID: " + a.id.toString() + ", Name: " + a.name + ", Faculty: " + a.faculty + ", Acquired Date: " + a.acquiredDate + ", Department: " + a.department);
                }
            }
        }
        else if trimmedChoice == "3" {
            io:print("Enter faculty name to filter: ");
            string|error faculty = io:readln();
            if faculty is error || faculty.trim().length() == 0 { io:println("Invalid input."); continue; }
            Asset[]|error assets = getAssetsByFaculty(faculty.trim());
            if assets is error { io:println("Error retrieving assets: " + assets.message()); }
            else if assets.length() == 0 { io:println("No assets found for faculty: " + faculty.trim()); }
            else {
                io:println("Assets in faculty '" + faculty.trim() + "':");
                foreach var a in assets {
                    io:println(" - ID: " + a.id.toString() + ", Name: " + a.name + ", Acquired Date: " + a.acquiredDate);
                }
            }
        }
        else if trimmedChoice == "4" {
            io:print("Enter today's date (YYYY-MM-DD): ");
            string|error currentDate = io:readln();
            if currentDate is error || currentDate.trim().length() == 0 {
                io:println("Invalid input."); 
                continue;
            }
            Asset[]|error overdue = checkOverdueItems(currentDate.trim());
            if overdue is error {
                io:println("Error checking overdue items: " + overdue.message());
            } else if overdue.length() == 0 {
                io:println("No overdue items found.");
            } else {
                io:println("Overdue Items:");
                foreach var asset in overdue {
                    io:println(" - ID: " + asset.id.toString() + ", Name: " +asset.name + ", Acquired Date: " + asset.acquiredDate);
                }
            }
        }
        else if trimmedChoice == "5" { check handleComponents(); }
        else if trimmedChoice == "6" {check handleSchedules(); }
         else if trimmedChoice == "7" {check handleWorkOrders(); }
        else if trimmedChoice == "8" { break; }
        else { io:println("Invalid choice. Try again."); }
    }
}

function handleWorkOrders() returns error? {
    io:print("Enter Asset ID to manage work orders: ");
    string|error idInput = io:readln();
    if idInput is error { io:println("Invalid input."); return; }
    int|error assetId = int:fromString(idInput.trim());
    if assetId is error { io:println("Invalid asset ID."); return; }

    while true {
        showWorkOrdersMenu();
        string|error choiceInput = io:readln();
        if choiceInput is error { io:println("Invalid input."); continue; }
        string choice = choiceInput.trim();

        if choice == "1" { // Add Work Order
            io:print("Enter work order description: ");
            string|error desc = io:readln();
            if desc is error || desc.trim().length() == 0 { io:println("Invalid input."); continue; }

            io:print("Enter work order status (OPEN/IN_PROGRESS/CLOSED): ");
            string|error status = io:readln();
            if status is error || status.trim().length() == 0 { io:println("Invalid input."); continue; }

            WorkOrder|error wo = addWorkOrder(assetId, { id: 0, description: desc.trim(), status: status.trim(), tasks: [] });
            if wo is error { io:println("Error adding work order: " + wo.message()); }
            else { io:println("Added work order: " + wo.toJsonString()); }

        } else if choice == "2" { // Update Work Order Status
            io:print("Enter work order ID: ");
            string|error woIdInput = io:readln();
            if woIdInput is error { io:println("Invalid input."); continue; }
            int|error woId = int:fromString(woIdInput.trim());
            if woId is error { io:println("Invalid work order ID."); continue; }

            io:print("Enter new status (OPEN/IN_PROGRESS/CLOSED): ");
            string|error status = io:readln();
            if status is error || status.trim().length() == 0 { io:println("Invalid input."); continue; }

            WorkOrder|error updated = updateWorkOrderStatus(assetId, woId, status.trim());
            if updated is error { io:println("Error updating work order: " + updated.message()); }
            else { io:println("Updated work order: " + updated.toJsonString()); }

        } 
          
         else if choice == "3" { 
            io:print("Enter work order ID: ");
            string|error woIdInput = io:readln();
            if woIdInput is error { io:println("Invalid input."); continue; }
            int|error woId = int:fromString(woIdInput.trim());
            if woId is error { io:println("Invalid work order ID."); continue; }

            check handleTasks(assetId, woId);

        }
        
         else if choice == "4" { 
            io:print("Enter work order ID: ");
            string|error woIdInput = io:readln();
            if woIdInput is error { io:println("Invalid input."); continue; }
            int|error woId = int:fromString(woIdInput.trim());
            if woId is error { io:println("Invalid work order ID."); continue; }

            check handleTasks(assetId, woId); 

        } else if choice == "5" { // Back
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
    }
}


function handleTasks(int assetId, int workOrderId) returns error? {
    while true {
        showTasksMenu();
        string|error choiceInput = io:readln();
        if choiceInput is error { io:println("Invalid input."); continue; }
        string choice = choiceInput.trim();

        if choice == "1" {
            io:print("Enter task description: ");
            string|error desc = io:readln();
            if desc is error || desc.trim().length() == 0 {
                io:println("Invalid input."); continue;
            }
            Task|error t = addTask(assetId, workOrderId, desc.trim());
            if t is error { io:println("Error adding task: " + t.message()); }
            else { io:println("Added task: " + t.toJsonString()); }

        } else if choice == "2" {
            io:print("Enter task ID to remove: ");
            string|error tidInput = io:readln();
            if tidInput is error { io:println("Invalid input."); continue; }
            int|error tid = int:fromString(tidInput.trim());
            if tid is error { io:println("Invalid ID."); continue; }

            string|error result = removeTask(assetId, workOrderId, tid);
            if result is error { io:println("Error: " + result.message()); }
            else { io:println(result); }

        } else if choice == "3" {
            break;
        } else {
            io:println("Invalid choice. Try again.");
        }
    }
}
// MAIN 
public function main() returns error? {
    io:println("Welcome to the Asset Management System!");
    while true {
        showMainMenu();
        string|error choice = io:readln();
        if choice is error { io:println("Invalid input."); continue; }

        string trimmedChoice = choice.trim();
        if trimmedChoice == "1" { 
            while true {
                io:println("\n--- Staff Login ---");
                io:println("1. Ndinelago");
                io:println("2. Chimba");
                io:println("3. Back to Main Menu");
                io:print("Enter choice: ");
                string|error staffChoice = io:readln();
                if staffChoice is error { 
                    io:println("Invalid input."); 
                    continue; 
                }

                string trimmedStaffChoice = staffChoice.trim();
                if trimmedStaffChoice == "1" {
                    io:println("Welcome, Ndinelago!");
                    check handleStaff(); 
                } else if trimmedStaffChoice == "2" {
                    io:println("Welcome, Chimba!");
                    check handleStaff(); 
                } else if trimmedStaffChoice == "3" {
                    break; 
                } else {
                    io:println("Invalid choice. Try again.");
                }
            } }
        else if trimmedChoice == "2" { io:println("Students functionality is not implemented yet."); }
        else if trimmedChoice == "3" { io:println("Exiting... GOOBBYE"); break; }
        else { io:println("Invalid choice. Try again."); }
    }
}

