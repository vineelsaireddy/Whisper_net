-- schema.sql
-- WhisperNet Database Schema
-- Phase 4 Implementation

DROP DATABASE IF EXISTS whispernet_db;
CREATE DATABASE whispernet_db;
USE whispernet_db;

-- --- STRONG ENTITIES ---

CREATE TABLE IntelligenceOfficer (
    OfficerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    `Rank` VARCHAR(50)
);

CREATE TABLE House (
    HouseID INT AUTO_INCREMENT PRIMARY KEY,
    HouseName VARCHAR(100) NOT NULL UNIQUE,
    Sigil VARCHAR(100),
    Words VARCHAR(255),
    SeatLocation VARCHAR(100),
    CurrentLord INT, 
    MilitaryStrength INT,
    WealthLevel INT
);

CREATE TABLE House_Regions (
    HouseID INT,
    RegionName VARCHAR(100),
    PRIMARY KEY (HouseID, RegionName),
    FOREIGN KEY (HouseID) REFERENCES House(HouseID) ON DELETE CASCADE
);

CREATE TABLE Location (
    LocationID INT AUTO_INCREMENT PRIMARY KEY,
    LocationName VARCHAR(100) NOT NULL,
    LocationType VARCHAR(50),
    Region VARCHAR(100),
    ControllingHouse INT,
    FOREIGN KEY (ControllingHouse) REFERENCES House(HouseID) ON DELETE SET NULL
);

CREATE TABLE Person (
    PersonID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    HouseID INT,
    CurrentLocationID INT,
    BirthYear INT,
    Status VARCHAR(50),
    StrategicImportance INT,
    LastVerifiedDate DATETIME,
    FOREIGN KEY (HouseID) REFERENCES House(HouseID) ON DELETE SET NULL,
    FOREIGN KEY (CurrentLocationID) REFERENCES Location(LocationID) ON DELETE SET NULL
);

CREATE TABLE Person_Titles (
    PersonID INT,
    Title VARCHAR(100),
    PRIMARY KEY (PersonID, Title),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

CREATE TABLE Agent (
    AgentID INT AUTO_INCREMENT PRIMARY KEY,
    RecruitmentDate DATETIME,
    CurrentStatus VARCHAR(50),
    CredibilityScore INT,
    ExposureRiskLevel VARCHAR(50),
    LastContactDate DATETIME,
    HandlerID INT,
    FOREIGN KEY (HandlerID) REFERENCES IntelligenceOfficer(OfficerID) ON DELETE SET NULL
);

CREATE TABLE EmbeddedAgent (
    AgentID INT PRIMARY KEY,
    PersonID INT,
    CoverIdentity VARCHAR(100),
    CoverOccupation VARCHAR(100),
    HouseInfiltrated INT,
    YearsDeepCover INT,
    ProximityToLeadership INT,
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE SET NULL,
    FOREIGN KEY (HouseInfiltrated) REFERENCES House(HouseID) ON DELETE SET NULL
);

CREATE TABLE LittleBird (
    AgentID INT PRIMARY KEY,
    CodeName VARCHAR(100),
    Age INT,
    OperatingCity VARCHAR(100),
    Specialization VARCHAR(100),
    MobilityLevel VARCHAR(50),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE
);

CREATE TABLE Intelligence (
    IntelligenceID INT AUTO_INCREMENT PRIMARY KEY,
    IntelligenceType VARCHAR(50),
    Content TEXT,
    DateGathered DATETIME,
    LocationGathered INT,
    CredibilityRating INT,
    VerificationStatus VARCHAR(50),
    StrategicValue INT,
    SensitivityLevel VARCHAR(50),
    FOREIGN KEY (LocationGathered) REFERENCES Location(LocationID) ON DELETE SET NULL
);

CREATE TABLE Secret (
    SecretID INT AUTO_INCREMENT PRIMARY KEY,
    SecretDescription TEXT,
    SecretCategory VARCHAR(50),
    DateDiscovered DATETIME,
    VerifiedStatus BOOLEAN,
    PotentialLeverage INT,
    RevealedStatus BOOLEAN
);

CREATE TABLE Event (
    EventID INT AUTO_INCREMENT PRIMARY KEY,
    EventType VARCHAR(50),
    EventName VARCHAR(100),
    DateOccurred DATETIME,
    LocationID INT,
    Description TEXT,
    ImpactLevel VARCHAR(50),
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID) ON DELETE SET NULL
);

CREATE TABLE Mission (
    MissionID INT AUTO_INCREMENT PRIMARY KEY,
    MissionObjective TEXT,
    TargetHouse INT,
    StartDate DATETIME,
    ExpectedCompletionDate DATETIME,
    Status VARCHAR(50),
    RiskLevel VARCHAR(50),
    FOREIGN KEY (TargetHouse) REFERENCES House(HouseID) ON DELETE SET NULL
);

-- --- RELATIONSHIP TABLES ---

CREATE TABLE Allegiance (
    SwornHouseID INT,
    LiegeHouseID INT,
    AllegianceStartDate DATETIME,
    AllegianceEndDate DATETIME,
    AllegianceStrength INT,
    Rationale TEXT,
    PRIMARY KEY (SwornHouseID, LiegeHouseID, AllegianceStartDate),
    FOREIGN KEY (SwornHouseID) REFERENCES House(HouseID) ON DELETE CASCADE,
    FOREIGN KEY (LiegeHouseID) REFERENCES House(HouseID) ON DELETE CASCADE
);

CREATE TABLE IntelligenceSource (
    IntelligenceID INT,
    AgentID INT,
    ContributionType VARCHAR(100),
    ReportConfidence INT,
    PRIMARY KEY (IntelligenceID, AgentID),
    FOREIGN KEY (IntelligenceID) REFERENCES Intelligence(IntelligenceID) ON DELETE CASCADE,
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE
);

CREATE TABLE Person_Secret (
    PersonID INT,
    SecretID INT,
    InvolvementType VARCHAR(100),
    PRIMARY KEY (PersonID, SecretID),
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE,
    FOREIGN KEY (SecretID) REFERENCES Secret(SecretID) ON DELETE CASCADE
);

CREATE TABLE Agent_Mission (
    AgentID INT,
    MissionID INT,
    AssignmentDate DATETIME,
    Role VARCHAR(100),
    SuccessContribution INT,
    PRIMARY KEY (AgentID, MissionID),
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE,
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE
);

CREATE TABLE Intelligence_Person_Concerns (
    IntelligenceID INT,
    PersonID INT,
    MentionContext TEXT,
    PRIMARY KEY (IntelligenceID, PersonID),
    FOREIGN KEY (IntelligenceID) REFERENCES Intelligence(IntelligenceID) ON DELETE CASCADE,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID) ON DELETE CASCADE
);

CREATE TABLE Intelligence_Verification (
    IntelligenceID INT,
    AgentID INT,
    OfficerID INT,
    VerificationDate DATETIME,
    OfficerConfidence INT,
    VerificationNotes TEXT,
    PRIMARY KEY (IntelligenceID, AgentID, OfficerID),
    FOREIGN KEY (IntelligenceID) REFERENCES Intelligence(IntelligenceID) ON DELETE CASCADE,
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE,
    FOREIGN KEY (OfficerID) REFERENCES IntelligenceOfficer(OfficerID) ON DELETE CASCADE
);

CREATE TABLE Mission_Deployment (
    MissionID INT,
    AgentID INT,
    IntelligenceID INT,
    LocationID INT,
    DeploymentDate DATETIME,
    DeploymentMethod VARCHAR(100),
    Outcome VARCHAR(100),
    PRIMARY KEY (MissionID, AgentID, IntelligenceID, LocationID),
    FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE CASCADE,
    FOREIGN KEY (AgentID) REFERENCES Agent(AgentID) ON DELETE CASCADE,
    FOREIGN KEY (IntelligenceID) REFERENCES Intelligence(IntelligenceID) ON DELETE CASCADE,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID) ON DELETE CASCADE
);