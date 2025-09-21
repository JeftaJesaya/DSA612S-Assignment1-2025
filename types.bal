// Core types for the Car Rental System
public type Car record {
    string make;
    string model;
    int year;
    float dailyPrice;
    int mileage;
    string plate;
    string status;
};

public type User record {
    string id;
    string name;
    string role;
};

public type CartItem record {
    string userId;
    string plate;
    string startDate;
    string endDate;
};

// Request types
public type AddCarRequest record {
    string make;
    string model;
    int year;
    float dailyPrice;
    int mileage;
    string plate;
    string status;
};

public type CreateUserRequest record {
    string id;
    string name;
    string role;
};

public type UpdateCarRequest record {
    string plate;
    string? make;
    string? model;
    int? year;
    float? dailyPrice;
    int? mileage;
    string? status;
};

public type PlateRequest record {
    string plate;
};

public type FilterRequest record {
    string keyword;
    int? year;
};

public type ReservationRequest record {
    string userId;
};

public type CreateUsersRequest record {
    User[] users;
};

// Response types
public type CarResponse record {
    Car car?;
    string message;
};

public type CreateUsersResponse record {
    string message;
    int usersCreated;
};

public type RemoveCarResponse record {
    string message;
    Car[] remainingCars;
};

public type ListCarsResponse record {
    Car[] cars;
    string message;
};

public type CartResponse record {
    string message;
};

public type ReservationResponse record {
    string message;
    float totalPrice;
};
