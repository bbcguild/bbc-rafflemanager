# Development Dockerfile
# Uses rafflebase image which contains Python environment and dependencies
FROM technitaur/rafflebase:latest

# Copy application code
COPY . .

# Copy template database if needed for development
# Don't copy the actual raffle.db - let init_db.py handle this
RUN if [ ! -f raffle.db ] && [ -f raffle_template.db ]; then \
        cp raffle_template.db raffle.db; \
        echo "Using template database for development"; \
    fi

# Expose port
EXPOSE 80

# Development command - run initialization then start app
CMD ["sh", "-c", "python init_db.py && python wsgi.py"]
