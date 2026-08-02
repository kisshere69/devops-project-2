FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# A non-root user and group for running the app
RUN addgroup --system app && \
    adduser --system --ingroup app app

# Passing the rights to the app user to access the /app
RUN chown -R app:app /app

USER app

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]