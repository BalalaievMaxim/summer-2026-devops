using Microsoft.EntityFrameworkCore;
using mywebapp.Data;
using mywebapp.Endpoints;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddJsonFile("/etc/mywebapp/config.json", optional: true, reloadOnChange: true);

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
                       ?? "Host=127.0.0.1;Database=mywebappdb;Username=postgres;Password=postgres";

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(8000);
});

var app = builder.Build();

app.MapSystemEndpoints();
app.MapNotesEndpoints();

app.Run();