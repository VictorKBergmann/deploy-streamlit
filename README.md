# deploy-streamlit

docker build -t deploy-streamlit .
docker run --rm -p 8501:8501 --env-file app/.env deploy-streamlit