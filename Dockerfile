FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5187
ENV ASPNETCORE_URLS=http://+:5187

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["EventBa.API/EventBa.API.csproj", "EventBa.API/"]
COPY ["EventBa.Model/EventBa.Model.csproj", "EventBa.Model/"]
COPY ["EventBa.Services/EventBa.Services.csproj", "EventBa.Services/"]
RUN dotnet restore "EventBa.API/EventBa.API.csproj"
COPY . .
WORKDIR "/src/EventBa.API"
RUN dotnet build "EventBa.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EventBa.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "EventBa.API.dll"]

