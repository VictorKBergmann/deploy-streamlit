FROM python:3.10-slim

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

# Streamlit default port
EXPOSE 8501 

CMD ["streamlit", "run", "app.py"]