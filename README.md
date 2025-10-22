# deploy-streamlit

# Building and running container
docker build -t deploy-streamlit .
docker run --rm -p 8501:8501 --env-file app/.env deploy-streamlit

# Pushing container to dockerhub
docker tag victorkberg/deploy-streamlit:latest victorkberg/deploy-streamlit:v?.?
docker push victorkberg/deploy-streamlit