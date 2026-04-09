# CCS Patient Self-Management Tool — Implementation Plan

## Project Overview

A mobile-first web application digitizing the "Your Health After a Heart Attack" self-management guide from the Canadian Cardiovascular Society (CCS). The app walks patients through a 5-step recovery journey covering care planning, medication tracking, appointment management, lifestyle goals, and care team contacts.

**Stack:** Vue 3 + TypeScript + Composition API · .NET 9 Web API · PostgreSQL 16

---

## Tech Stack & Rationale

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Vue 3 + TypeScript + Composition API | Mobile-first SPA |
| State Management | Pinia | Auth state, per-step data |
| HTTP Client | Axios | API calls with JWT interceptor |
| Router | Vue Router 4 | Step navigation + auth guards |
| UI | Tailwind CSS | Responsive mobile-first styling |
| Backend | .NET 9 Web API | REST API, business logic |
| ORM | Entity Framework Core 9 | DB access |
| Auth | ASP.NET Core Identity + JWT | User accounts + token auth |
| Database | PostgreSQL 16 | Persistent data store |

---

## Repository Structure

```
/
├── frontend/                   # Vue 3 app
│   ├── src/
│   │   ├── assets/
│   │   ├── components/         # Shared components (InfoCard, DataTable, etc.)
│   │   ├── views/
│   │   │   ├── auth/
│   │   │   │   ├── LoginView.vue
│   │   │   │   └── RegisterView.vue
│   │   │   └── steps/
│   │   │       ├── Step1CarePlan.vue
│   │   │       ├── Step2Medications.vue
│   │   │       ├── Step3Appointments.vue
│   │   │       ├── Step4Lifestyle.vue
│   │   │       └── Step5CareTeam.vue
│   │   ├── stores/
│   │   │   ├── auth.ts
│   │   │   └── carePlan.ts
│   │   ├── router/
│   │   │   └── index.ts
│   │   ├── services/
│   │   │   └── api.ts          # Axios instance + interceptors
│   │   └── main.ts
│   ├── index.html
│   └── vite.config.ts
│
└── backend/                    # .NET 9 Web API
    ├── Controllers/
    │   ├── AuthController.cs
    │   ├── CarePlanController.cs
    │   ├── MedicationsController.cs
    │   ├── AppointmentsController.cs
    │   ├── LifestyleController.cs
    │   └── CareTeamController.cs
    ├── Models/
    │   ├── ApplicationUser.cs
    │   ├── CarePlan.cs
    │   ├── Medication.cs
    │   ├── Appointment.cs
    │   ├── LifestyleGoal.cs
    │   └── CareTeamContact.cs
    ├── Data/
    │   └── AppDbContext.cs
    ├── DTOs/                   # Request/response shapes
    ├── Program.cs
    └── appsettings.json
```

---

## Phase 1: Project Setup

### 1.1 Frontend Scaffolding

```bash
npm create vue@latest frontend
# Select: TypeScript, Vue Router, Pinia

cd frontend
npm install axios tailwindcss @tailwindcss/forms
npx tailwindcss init
```

Configure `tailwind.config.js` for mobile-first breakpoints and add the Tailwind directives to `src/assets/main.css`.

### 1.2 Backend Scaffolding

```bash
dotnet new webapi -n backend --framework net9.0
cd backend

dotnet add package Microsoft.AspNetCore.Identity.EntityFrameworkCore
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package Microsoft.EntityFrameworkCore.Design
```

### 1.3 Database Setup

Create a Postgres database locally:

```sql
CREATE DATABASE ccs_heartattack;
```

Add the connection string to `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "Default": "Host=localhost;Database=ccs_heartattack;Username=postgres;Password=yourpassword"
  },
  "Jwt": {
    "Key": "your-secret-key-minimum-32-chars-long",
    "Issuer": "ccs-api",
    "Audience": "ccs-app",
    "ExpiryHours": 24
  }
}
```

---

## Phase 2: Authentication

### 2.1 Backend — Identity + JWT Setup

**`Data/AppDbContext.cs`**
```csharp
public class AppDbContext : IdentityDbContext<ApplicationUser>
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

    public DbSet<Medication> Medications => Set<Medication>();
    public DbSet<Appointment> Appointments => Set<Appointment>();
    public DbSet<LifestyleGoal> LifestyleGoals => Set<LifestyleGoal>();
    public DbSet<CareTeamContact> CareTeamContacts => Set<CareTeamContact>();
    public DbSet<CarePlan> CarePlans => Set<CarePlan>();
}
```

**`Program.cs`**
```csharp
builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

builder.Services.AddIdentity<ApplicationUser, IdentityRole>()
    .AddEntityFrameworkStores<AppDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(opt => {
        opt.TokenValidationParameters = new TokenValidationParameters {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

builder.Services.AddCors(opt => opt.AddPolicy("Dev", p =>
    p.WithOrigins("http://localhost:5173").AllowAnyHeader().AllowAnyMethod()));

// ...
app.UseCors("Dev");
app.UseAuthentication();
app.UseAuthorization();
```

**`Controllers/AuthController.cs`**
```csharp
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly IConfiguration _config;

    public AuthController(UserManager<ApplicationUser> userManager, IConfiguration config)
    {
        _userManager = userManager;
        _config = config;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var user = new ApplicationUser { UserName = dto.Email, Email = dto.Email };
        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded) return BadRequest(result.Errors);
        return Ok(new { message = "Account created" });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user == null || !await _userManager.CheckPasswordAsync(user, dto.Password))
            return Unauthorized("Invalid credentials");

        var token = GenerateJwt(user);
        return Ok(new { token });
    }

    private string GenerateJwt(ApplicationUser user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id),
            new Claim(ClaimTypes.Email, user.Email!)
        };
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"],
            audience: _config["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(double.Parse(_config["Jwt:ExpiryHours"]!)),
            signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
```

Run migrations to create all Identity tables:

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

### 2.2 Frontend — Auth Store + Axios Interceptor

**`src/services/api.ts`**
```typescript
import axios from 'axios'
import { useAuthStore } from '@/stores/auth'

const api = axios.create({ baseURL: 'http://localhost:5000/api' })

api.interceptors.request.use(config => {
  const auth = useAuthStore()
  if (auth.token) config.headers.Authorization = `Bearer ${auth.token}`
  return config
})

export default api
```

**`src/stores/auth.ts`**
```typescript
import { defineStore } from 'pinia'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: sessionStorage.getItem('token') ?? null as string | null
  }),
  getters: {
    isAuthenticated: (state) => !!state.token
  },
  actions: {
    async login(email: string, password: string) {
      const { data } = await api.post('/auth/login', { email, password })
      this.token = data.token
      sessionStorage.setItem('token', data.token)
    },
    async register(email: string, password: string) {
      await api.post('/auth/register', { email, password })
    },
    logout() {
      this.token = null
      sessionStorage.removeItem('token')
    }
  }
})
```

**`src/router/index.ts`** — protect all step routes:
```typescript
router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login' }
  }
})
```

Mark step routes with `meta: { requiresAuth: true }`.

---

## Phase 3: Data Models

Each model includes a `UserId` foreign key so all data is scoped to the authenticated patient.

```csharp
// Medication.cs
public class Medication
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Name { get; set; } = "";
    public string Reason { get; set; } = "";
    public string DosageInstructions { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

// Appointment.cs
public class Appointment
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public DateTime AppointmentDate { get; set; }
    public string ProviderName { get; set; } = "";
    public string Purpose { get; set; } = "";
    public string Notes { get; set; } = "";
}

// LifestyleGoal.cs
public class LifestyleGoal
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Category { get; set; } = ""; // ShortTerm | LongTerm | Health | Personal
    public string Text { get; set; } = "";
    public bool IsCompleted { get; set; } = false;
}

// CareTeamContact.cs
public class CareTeamContact
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string Role { get; set; } = ""; // FamilyDoctor | Cardiologist | Pharmacist | Dietician | Other
    public string Name { get; set; } = "";
    public string Contact { get; set; } = "";
}

// CarePlan.cs (Step 1 — one record per user)
public class CarePlan
{
    public int Id { get; set; }
    public string UserId { get; set; } = "";
    public string TreatmentReceived { get; set; } = "";
    public string Notes { get; set; } = "";
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
```

Add all `DbSet<>` properties to `AppDbContext`, then run:

```bash
dotnet ef migrations add AddCarePlanModels
dotnet ef database update
```

---

## Phase 4: API Endpoints

All controllers follow the same pattern — resolve `UserId` from the JWT claim and scope all queries to that user.

```csharp
private string UserId => User.FindFirstValue(ClaimTypes.NameIdentifier)!;
```

### Endpoint Reference

| Method | Route | Description |
|---|---|---|
| POST | `/api/auth/register` | Create account |
| POST | `/api/auth/login` | Login, returns JWT |
| GET/PUT | `/api/careplan` | Get or update Step 1 data |
| GET | `/api/medications` | List medications |
| POST | `/api/medications` | Add medication |
| DELETE | `/api/medications/{id}` | Remove medication |
| GET | `/api/appointments` | List appointments |
| POST | `/api/appointments` | Add appointment |
| DELETE | `/api/appointments/{id}` | Remove appointment |
| GET | `/api/lifestyle` | List all goals |
| POST | `/api/lifestyle` | Add goal |
| PATCH | `/api/lifestyle/{id}/toggle` | Toggle complete |
| DELETE | `/api/lifestyle/{id}` | Remove goal |
| GET | `/api/careteam` | List contacts |
| POST | `/api/careteam` | Add contact |
| DELETE | `/api/careteam/{id}` | Remove contact |

Apply `[Authorize]` to all controllers except `AuthController`.

---

## Phase 5: Frontend — Step Implementation

### Navigation Shell

The main layout after login is a tab bar with 5 steps. On mobile this renders as a bottom nav; on desktop as a sidebar or top nav.

```vue
<!-- src/App.vue (post-auth layout) -->
<nav class="fixed bottom-0 w-full flex justify-around bg-white border-t md:hidden">
  <RouterLink to="/step/1">Care Plan</RouterLink>
  <RouterLink to="/step/2">Medications</RouterLink>
  <RouterLink to="/step/3">Appointments</RouterLink>
  <RouterLink to="/step/4">Lifestyle</RouterLink>
  <RouterLink to="/step/5">Care Team</RouterLink>
</nav>
```

### Step 1 — Care Plan (`Step1CarePlan.vue`)

- Text area: "What were you treated with?"
- Text area: "Notes"
- Two `InfoCard` components (collapsible or always visible):
  - **Before you leave hospital** — renders the 9 bullet points from the guide
  - **After you leave hospital** — renders the 2 follow-up bullet points
- Save button calls `PUT /api/careplan`

### Step 2 — Medications (`Step2Medications.vue`)

- Form fields: Medication name, reason for taking, dosage/instructions
- Submit calls `POST /api/medications`
- Results table columns: Name · Reason · Dosage/Instructions · Delete

### Step 3 — Appointments (`Step3Appointments.vue`)

- Form fields: Date (date picker), Provider name, Purpose, Notes (textarea)
- Submit calls `POST /api/appointments`
- Results table columns: Date · Provider · Purpose · Notes · Delete

### Step 4 — Lifestyle Goals (`Step4Lifestyle.vue`)

Four separate to-do lists, each with its own add-item input:

| List | `category` value |
|---|---|
| Short term goals | `ShortTerm` |
| Long term goals | `LongTerm` |
| Health goals | `Health` |
| Personal goals | `Personal` |

Completed items display with `line-through` styling — they are never deleted, just toggled via `PATCH /api/lifestyle/{id}/toggle`.

### Step 5 — Care Team (`Step5CareTeam.vue`)

Five contact sections (Family Doctor, Cardiologist, Pharmacist, Registered Dietician, Other), each with Name and Contact fields. All saved contacts across all roles display in a single table:

Results table columns: Role · Name · Contact · Delete

---

## Phase 6: Shared Components

Build these reusable components to keep step views lean:

| Component | Props | Description |
|---|---|---|
| `InfoCard.vue` | `title`, `items: string[]` | Collapsible card with bullet list |
| `DataTable.vue` | `columns`, `rows`, `onDelete` | Generic table with delete action |
| `TodoList.vue` | `category`, `title` | Self-contained to-do list for Step 4 |
| `ContactSection.vue` | `role` | Name + contact inputs for Step 5 |
| `FormInput.vue` | `label`, `modelValue`, `type` | Labeled input with v-model |

---

## Phase 7: External Resources

Add a **Resources** tab or footer link pointing to the CCS educational content:

```
https://ccs.ca/afterheartattack/
```

This can be a simple static page with curated links to the CCS site — no backend required.

---

## Implementation Order (Hackathon Timeline)

| Priority | Task | Est. Time |
|---|---|---|
| 1 | Project scaffolding (frontend + backend) | 1 hr |
| 2 | Authentication (Identity + JWT + Vue store) | 2–3 hr |
| 3 | DB models + EF migrations | 1 hr |
| 4 | Core API endpoints (CRUD for all 5 steps) | 2 hr |
| 5 | Vue routing + auth guard + nav shell | 1 hr |
| 6 | Step 1: Care Plan UI | 1 hr |
| 7 | Step 2: Medications UI | 1 hr |
| 8 | Step 3: Appointments UI | 1 hr |
| 9 | Step 4: Lifestyle Goals UI | 1.5 hr |
| 10 | Step 5: Care Team UI | 1 hr |
| 11 | Polish: mobile layout, InfoCards, resources link | 1–2 hr |

**Total estimate: ~14–16 hours**

---

## Quick Reference: Key Commands

```bash
# Run backend
cd backend && dotnet run

# Run frontend
cd frontend && npm run dev

# Add a new EF migration
dotnet ef migrations add <MigrationName>

# Apply migrations
dotnet ef database update

# Build frontend for production
npm run build
```

---

## Notes

- All patient data is scoped by `UserId` extracted from the JWT — never trust a user-supplied ID in the request body for ownership checks.
- Use `sessionStorage` (not `localStorage`) for the JWT token given the sensitivity of health data; it clears automatically when the browser tab closes.
- CORS is configured for `http://localhost:5173` (Vite dev server default) — update the origin if your setup differs.
- For the hackathon, a 24-hour token expiry with no refresh token flow is sufficient.
- The `[Authorize]` attribute on controllers combined with the Axios interceptor means protected API calls will automatically return 401 if the token is missing or expired — handle this in the interceptor by redirecting to `/login`.
