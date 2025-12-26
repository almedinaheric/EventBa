FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["EventBa.Subscriber/EventBa.Subscriber.csproj", "EventBa.Subscriber/"]
COPY ["EventBa.Model/EventBa.Model.csproj", "EventBa.Model/"]
RUN dotnet restore "EventBa.Subscriber/EventBa.Subscriber.csproj"
COPY . .
WORKDIR "/src/EventBa.Subscriber"
RUN dotnet build "EventBa.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EventBa.Subscriber.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "EventBa.Subscriber.dll"]

