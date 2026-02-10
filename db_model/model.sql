CREATE EXTENSION IF NOT EXISTS postgis;

-- Tables
DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS offer CASCADE;
DROP TABLE IF EXISTS need CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;
DROP TABLE IF EXISTS administrative_area CASCADE;
DROP TABLE IF EXISTS facility CASCADE;

-- App Users
CREATE TABLE app_user (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    firstname VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Needs (requests for help)
CREATE TABLE need (
    need_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    descrip TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    urgency VARCHAR(20) NOT NULL CHECK (urgency IN ('critical', 'high', 'medium', 'low')),
    geom GEOMETRY(Point, 3763) NOT NULL,
    address_point VARCHAR(500),
    status_need VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status_need IN ('active', 'assigned', 'resolved', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_need_user FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE CASCADE
);

-- Offers (volunteer availability)
CREATE TABLE offer (
    offer_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    descrip TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    available VARCHAR(20) NOT NULL CHECK (available IN ('immediate', 'today', 'this_week', 'on_call')),
    geom GEOMETRY(Point, 3763),
    status_offer VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status_offer IN ('available', 'assigned', 'unavailable')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_offer_user FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE CASCADE

);

-- Assignments (matching needs with offers)
CREATE TABLE assignments (
    assignment_id SERIAL PRIMARY KEY,
    need_id INTEGER UNIQUE NOT NULL,
    offer_id INTEGER UNIQUE NOT NULL,
    status_ass VARCHAR(20) NOT NULL DEFAULT 'proposed' CHECK (status_ass IN ('proposed', 'accepted', 'rejected', 'completed')),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    CONSTRAINT fk_need_assignment FOREIGN KEY (need_id) REFERENCES need(need_id) ON DELETE CASCADE,
    CONSTRAINT fk_offer_assignment FOREIGN KEY (offer_id) REFERENCES offer(offer_id) ON DELETE CASCADE
);


-- Tables from OSM

-- Administrative Areas (from OSM)
CREATE TABLE administrative_area (
    area_id SERIAL PRIMARY KEY,
    name_area VARCHAR(100) NOT NULL,
    admin_level INTEGER NOT NULL,
    geom GEOMETRY(Polygon, 3763) NOT NULL
);

-- Emergency Facilities (from OSM)
CREATE TABLE facility (
    facility_id SERIAL PRIMARY KEY,
    osm_id BIGINT,
    name_fac VARCHAR(255),
    facility_type VARCHAR(50) NOT NULL,
    geom GEOMETRY(Point, 3763) NOT NULL
);


-- triggers

-- spatial queries on needs (e.g., "needs within 5km")
CREATE INDEX idx_need_geom ON need USING GIST (geom);

-- spatial queries on offers (e.g., "offers near a point")
CREATE INDEX idx_offer_geom ON offer USING GIST (geom);

-- filtering by administrative area (e.g., "needs in Lisbon")
CREATE INDEX idx_admin_area_geom ON administrative_area USING GIST (geom);

-- finding nearby facilities (e.g., "hospitals near a need")
CREATE INDEX idx_facility_geom ON facility USING GIST (geom);

-- triggers for updated_at timestamps


-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for need table
CREATE TRIGGER update_need_updated_at
    BEFORE UPDATE ON need
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for offer table
CREATE TRIGGER update_offer_updated_at
    BEFORE UPDATE ON offer
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
