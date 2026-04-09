import os

dirs = [
    r'C:\Users\echos\source\repos\hackathon_ai\frontend',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\assets',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\services',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\stores',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\router',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\components',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\views',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\views\auth',
    r'C:\Users\echos\source\repos\hackathon_ai\frontend\src\views\steps',
]

for d in dirs:
    os.makedirs(d, exist_ok=True)
    print(f'Created: {d}')

print('All directories created successfully!')
