FROM ruby:3.2.2

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    nodejs \
    pkg-config \
    git \
    curl \
    libssl-dev \
    libyaml-dev \
    libcurl4-openssl-dev

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./

# Install specific bundler version
RUN gem install bundler -v 2.4.22

# Install dependencies
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"] 