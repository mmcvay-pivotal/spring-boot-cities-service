CREATE TABLE uktowns (
  ID int IDENTITY(1,1) PRIMARY KEY,
  Name varchar(2000) DEFAULT NULL,
  County varchar(255) NOT NULL,
  Country varchar(255) NOT NULL,
  GridRef varchar(10) NOT NULL,
  Latitude decimal(10,5) DEFAULT NULL,
  Longitude decimal(10,5) DEFAULT NULL,
  Easting int NOT NULL,
  Northing int NOT NULL,
  Postcode varchar(10) NOT NULL,
  Type varchar(255) NOT NULL,
);