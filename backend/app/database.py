from sqlalchemy import create_engine
from sqlalchemy.engine import make_url
from sqlalchemy.exc import OperationalError
from sqlalchemy.orm import sessionmaker, declarative_base

from app.config import DATABASE_URL

engine_url = make_url(DATABASE_URL)
connect_args = {}
if engine_url.drivername.startswith("sqlite"):
    connect_args = {"check_same_thread": False}

try:
    engine = create_engine(DATABASE_URL, connect_args=connect_args)
    with engine.connect() as connection:
        connection.execute("SELECT 1")
except OperationalError:
    fallback_url = "sqlite:///./jme.db"
    engine = create_engine(fallback_url, connect_args={"check_same_thread": False})

SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
Base = declarative_base()

