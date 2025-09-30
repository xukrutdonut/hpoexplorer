# Dockerfile for Raspberry Pi 5 (ARM64)
# Based on Rocker's R base image with ARM64 support

FROM rocker/rstudio:latest

LABEL org.opencontainers.image.authors="neurogenomics"
LABEL org.opencontainers.image.description="HPOExplorer - Analysis and Visualisation of the Human Phenotype Ontology"
LABEL org.opencontainers.image.source="https://github.com/neurogenomics/HPOExplorer"

# Install system dependencies required for R packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    git \
    wget \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libicu-dev \
    libgit2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install BiocManager
RUN R -e "install.packages('BiocManager', repos='https://cloud.r-project.org/')"

# Install remotes package (required for GitHub installations)
RUN R -e "BiocManager::install('remotes', ask=FALSE, update=TRUE)"

# Install HPOExplorer and its dependencies
# This will pull from the latest GitHub release or use BiocManager
RUN R -e "BiocManager::install('neurogenomics/HPOExplorer', ask=FALSE, update=TRUE)"

# Set working directory
WORKDIR /home/rstudio

# Expose RStudio port
EXPOSE 8787

# Default command (RStudio server is started by the base image)
CMD ["/init"]
