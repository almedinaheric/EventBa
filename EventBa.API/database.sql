-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE event_status AS ENUM ('UPCOMING', 'PAST', 'CANCELED');
CREATE TYPE event_type AS ENUM ('PUBLIC', 'PRIVATE');
CREATE TYPE payment_status AS ENUM ('PENDING', 'PAID', 'REFUNDED', 'FAILED');
CREATE TYPE notification_status AS ENUM ('SENT', 'READ', 'ARCHIVED');
CREATE TYPE image_type AS ENUM ('PROFILE_IMAGE', 'EVENT_COVER', 'EVENT_GALLERY');
CREATE TYPE user_role AS ENUM ('ADMIN', 'CUSTOMER');

-- Create tables
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    bio TEXT,
    profile_image_id UUID,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    role_id UUID NOT NULL REFERENCES roles(id),
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Add computed column for full_name
ALTER TABLE users ADD COLUMN full_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED;

CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    event_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    social_media_links JSONB,
    cover_image_id UUID,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    capacity INTEGER NOT NULL,
    current_attendees INTEGER NOT NULL DEFAULT 0,
    available_tickets_count INTEGER NOT NULL DEFAULT 0,
    status event_status NOT NULL DEFAULT 'UPCOMING',
    category_id UUID NOT NULL REFERENCES categories(id),
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    type event_type NOT NULL,
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    organizer_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_dates CHECK (end_date >= start_date),
    CONSTRAINT chk_capacity CHECK (capacity > 0),
    CONSTRAINT chk_attendees CHECK (current_attendees <= capacity)
);

CREATE TABLE event_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    total_views INTEGER NOT NULL DEFAULT 0,
    total_favorites INTEGER NOT NULL DEFAULT 0,
    total_tickets_sold INTEGER NOT NULL DEFAULT 0,
    total_revenue DECIMAL(10, 2) NOT NULL DEFAULT 0,
    average_rating DECIMAL(3, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating CHECK (average_rating >= 0 AND average_rating <= 5)
);

CREATE TABLE event_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    ticket_type VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL,
    quantity_available INTEGER NOT NULL,
    quantity_sold INTEGER NOT NULL DEFAULT 0,
    sale_start_date TIMESTAMP   NOT NULL,
    sale_end_date TIMESTAMP   NOT NULL,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_available CHECK (quantity_available <= quantity),
    CONSTRAINT chk_sold CHECK (quantity_sold <= quantity),
    CONSTRAINT chk_dates CHECK (sale_end_date >= sale_start_date)
);

CREATE TABLE ticket_purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- QR Code System (3-layer verification)
    qr_verification_hash VARCHAR(128) NOT NULL,  -- Secured hash of ticket data
    qr_data TEXT NOT NULL,                      -- Structured ticket data (JSON/encoded)
    qr_code_image BYTEA,                       -- Optional pre-generated QR image
    
    -- Human-readable identifiers
    ticket_code VARCHAR(20) NOT NULL UNIQUE,    -- Short code for manual entry
    
    -- Usage tracking
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    used_at TIMESTAMP,
    
    -- Security
    is_valid BOOLEAN NOT NULL DEFAULT TRUE,
    invalidated_at TIMESTAMP,
    
    -- Base entity fields
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    event_id UUID NOT NULL REFERENCES events(id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status payment_status NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_amount CHECK (amount >= 0)
);

CREATE TABLE favorite_events (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, event_id)
);

CREATE TABLE user_interests (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, category_id)
);

CREATE TABLE event_tags (
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, tag_id)
);

CREATE TABLE user_connections (
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, following_id),
    CONSTRAINT chk_no_self_follow CHECK (follower_id <> following_id)
);

CREATE TABLE user_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    question TEXT NOT NULL,
    answer TEXT,
    is_question_for_admin BOOLEAN NOT NULL DEFAULT FALSE,
    is_answered BOOLEAN NOT NULL DEFAULT FALSE,
    asked_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    answered_at TIMESTAMP  ,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_no_self_question CHECK (user_id <> receiver_id)
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    is_system_notification BOOLEAN NOT NULL DEFAULT FALSE,
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    is_important BOOLEAN NOT NULL DEFAULT FALSE,
    status notification_status NOT NULL DEFAULT 'SENT',
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    image_type image_type NOT NULL,
    order INTEGER,
    file_name VARCHAR(255) NOT NULL,
    file_size INTEGER,
    image_data BYTEA,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recommended_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_id1 UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    event_id2 UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_different_events CHECK (event_id1 <> event_id2)
);

CREATE TABLE event_gallery_images (
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    image_id UUID NOT NULL REFERENCES images(id) ON DELETE CASCADE,
    order INTEGER NOT NULL,
    PRIMARY KEY (event_id, image_id)
);

-- Add foreign key constraints that reference images
ALTER TABLE users ADD CONSTRAINT fk_user_profile_image 
    FOREIGN KEY (profile_image_id) REFERENCES images(id) ON DELETE SET NULL;

ALTER TABLE events ADD CONSTRAINT fk_event_cover_image 
    FOREIGN KEY (cover_image_id) REFERENCES images(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX idx_events_organizer ON events(organizer_id);
CREATE INDEX idx_events_category ON events(category_id);
CREATE INDEX idx_events_status ON events(status);
CREATE INDEX idx_events_type ON events(type);
CREATE INDEX idx_tickets_event ON tickets(event_id);
CREATE INDEX idx_ticket_purchases_user ON ticket_purchases(user_id);
CREATE INDEX idx_ticket_purchases_event ON ticket_purchases(event_id);
CREATE INDEX idx_event_reviews_event ON event_reviews(event_id);
CREATE INDEX idx_event_reviews_user ON event_reviews(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_event ON notifications(event_id);
CREATE INDEX idx_user_questions_user ON user_questions(user_id);
CREATE INDEX idx_user_questions_receiver ON user_questions(receiver_id);

-- Insert initial roles
INSERT INTO roles (id, name) VALUES 
    (uuid_generate_v4(), 'ADMIN'),
    (uuid_generate_v4(), 'CUSTOMER');

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;