CREATE EXTENSION IF NOT EXISTS plpython3u;

DO $$
import sys
plpy.notice(f"PL/Python успешно установлен! Версия: {sys.version}")
$$ LANGUAGE plpython3u;