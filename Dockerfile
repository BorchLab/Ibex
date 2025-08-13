FROM rocker/verse:4.5.1
RUN apt-get update && apt-get install -y texlive-fonts-extra
WORKDIR /Ibex
COPY . .
RUN Rscript -e "remotes::install_deps(dependencies = TRUE)"
RUN Rscript -e "install.packages('BiocManager')"
RUN Rscript -e "BiocManager::install('scRepertoire')"
RUN Rscript -e "BiocManager::install('basilisk')"
RUN Rscript -e "devtools::document(); devtools::test()"
