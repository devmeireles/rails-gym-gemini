
# Coacher App - Diet and Workout Plan Generator

This is a Rails-based web application designed to help users generate personalized workout and diet plans based on their preferences and needs. The app leverages AI-powered content generation (via API) to create customized workout and diet plans in response to user inputs.

## Features
-   **Personalized Diet Plans**: The application generates custom diet plans based on user information such as age, weight, height, sex, activity level, and dietary preferences.
-   **Personalized Workout Plans**: The application generates custom workout routines based on user objectives, fitness level, and preferences.
-   **AI Integration**: The app uses a third-party AI API to generate responses for both diet and workout plans based on user input.
-   **Seamless User Experience**: Users simply provide input about their diet or workout needs, and the application returns a well-structured plan in JSON format.

## Technologies

-   **Ruby on Rails**: The backend is built with Ruby on Rails to manage the API endpoints, database, and web interface.
-   **AI API Integration**: The application calls an external API for generating workout and diet plans based on user input.
-   **JSON Output**: Both workout and diet plans are returned in a structured JSON format, making them easy to interpret and display.

## Setup
To get this application up and running locally, follow the instructions below.

### Prerequisites

-   Ruby 3.x or higher
-   Rails 6.x or higher
-   PostgreSQL (or any database of your choice)
-   API Key for the AI API (e.g., Gemini API)

### Installation

1.  **Clone the Repository**:
```bash
git clone https://github.com/devmeireles/rails-gym-gemini.git
cd rails-gym-gemini
```

2. **Install Dependencies**:
Make sure you have the required Ruby and Rails versions installed, then run the following commands:

```bash
bundle install
```

3. **Setup Environment Variables**:
The application uses an external AI API for generating workout and diet plans. You’ll need to set up environment variables to provide the API key and base URL.

In the root of your project, create a `.env` file (or use any method to manage environment variables):

```bash
API_KEY=your_api_key_here
BASE_URL=https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=
```
4. **Start the Rails Server**:

Run the server locally:
```bash
rails server
```

## API Endpoints

### Generate Workout Plan

**URL**: `POST /plans/generate/workout`

This endpoint generates a personalized workout plan based on the user's input. The user must provide information regarding their fitness goals, experience level, and any other preferences.

#### Request

```bash
POST /plans/generate/workout
Content-Type: application/json

{
  "plan_type": "workout",
  "plan_data": {
    "weight": 80,
    "height": 1.85,
    "age": 30,
    "sex": "Male",
    "activity_level": "Moderate exercise (4-6 days/week)",
    "goal": "Muscle gain",
    "experience": "Intermediate",
    "preferred_exercise_type": "Push-Pull-Legs"
  }
}
```

#### Example Response
```json
{
  "day_1": [
    {
      "exercise_name": "Barbell Squats",
      "sets": 4,
      "reps": 8,
      "weight": "80% of 1RM",
      "rest_time": "90 seconds"
    },
    {
      "exercise_name": "Leg Press",
      "sets": 3,
      "reps": 10,
      "weight": "Moderate-Heavy",
      "rest_time": "75 seconds"
    }
  ],
  "day_2": [
    {
      "exercise_name": "Bench Press",
      "sets": 4,
      "reps": 8,
      "weight": "80% of 1RM",
      "rest_time": "90 seconds"
    },
    {
      "exercise_name": "Incline Dumbbell Press",
      "sets": 3,
      "reps": 10,
      "weight": "Moderate-Heavy",
      "rest_time": "75 seconds"
    }
  ]
}
```

### Generate Diet Plan

**URL**: `POST /plans/generate/diet`

This endpoint generates a personalized diet plan based on the user's input. The user provides details such as weight, height, age, sex, activity level, and any specific dietary preferences.

#### Request

```bash
POST /plans/generate/diet
Content-Type: application/json

{
  "plan_type": "diet",
  "plan_data": {
    "weight": 80,
    "height": 1.92,
    "age": 31,
    "sex": "Male",
    "activity_level": "Moderate exercise (4-6 days/week)"
  }
}
```

#### Example Response

```json
{
  "meal_1": [
    {
      "food_name": "Oatmeal",
      "calories": 150,
      "proteins": 6,
      "carbs": 28,
      "fat": 4,
      "quantity": "1 cup"
    },
    {
      "food_name": "Egg Whites",
      "calories": 80,
      "proteins": 17,
      "carbs": 1,
      "fat": 0,
      "quantity": "4 whites"
    }
  ],
  "meal_2": [
    {
      "food_name": "Grilled Chicken Breast",
      "calories": 300,
      "proteins": 40,
      "carbs": 0,
      "fat": 8,
      "quantity": "200g"
    },
    {
      "food_name": "Quinoa",
      "calories": 220,
      "proteins": 8,
      "carbs": 39,
      "fat": 4,
      "quantity": "1 cup"
    }
  ]
}
```