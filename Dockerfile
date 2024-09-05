# builder
FROM mcr.microsoft.com/dotnet/sdk:8.0-noble as builder
WORKDIR /app

RUN apt-get update && \
	apt-get upgrade -y && \
	rm -rf /var/lib/apt/lists/*

ARG ENVIRONMENT=Development
ENV ASPNETCORE_ENVIRONMENT $ENVIRONMENT

# restore
COPY ./Portfolio.API/Portfolio.API.csproj ./Portfolio.API/
COPY ./Portfolio.Models/Portfolio.Models.csproj ./Portfolio.Models/
RUN dotnet restore ./Portfolio.API/

# build
COPY ./Portfolio.API/ ./Portfolio.API/
COPY ./Portfolio.Models/ ./Portfolio.Models/
RUN dotnet publish ./Portfolio.API/Portfolio.API.csproj -c Release -o ./out

# runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0.6-noble
WORKDIR /app

RUN apt-get update && \ 
	apt-get upgrade -y && \
	rm -rf /var/lib/apt/lists/*

ARG ENVIRONMENT
ENV ASPNETCORE_ENVIRONMENT $ENVIRONMENT

COPY --from=builder /app/out .

# remove root
RUN groupadd -g 1000 portfolio-grp && \
    useradd -u 1000 -g portfolio-grp -m portfolio-usr
USER portfolio-usr

EXPOSE 8080
CMD ["dotnet", "Portfolio.API.dll"]