from sqlalchemy import text

def init_duckdb(engine, sql_dir):
    
    with engine.connect() as conn:
        conn.execute(text("LOAD spatial;"))
        conn.execute(text("INSTALL h3 FROM community;"))
        conn.execute(text("LOAD h3;"))

        conn.execute(text("SET threads to 1;"))