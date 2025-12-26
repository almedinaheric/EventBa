namespace EventBa.Services.Interfaces;

public interface IRabbitMQProducer
{
    public void SendMessage<T>(T message);
}

