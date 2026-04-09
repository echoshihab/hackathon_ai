namespace backend.Models;

public class LifestyleGoal
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Category { get; set; } = ""; // ShortTerm | LongTerm | Health | Personal
    public string Text { get; set; } = "";
    public bool IsCompleted { get; set; } = false;
}
