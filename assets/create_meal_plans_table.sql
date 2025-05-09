-- Create meal_plans table for storing user's meal planning data
CREATE TABLE IF NOT EXISTS public.meal_plans (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recipe_id INTEGER NOT NULL,
  recipe_title TEXT NOT NULL,
  recipe_image TEXT NOT NULL,
  date DATE NOT NULL,
  meal_type TEXT NOT NULL,
  servings INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  
  -- Add constraint to ensure valid meal_type values
  CONSTRAINT meal_type_check CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack'))
);

-- Create index for faster queries by date and user
CREATE INDEX IF NOT EXISTS meal_plans_user_date_idx ON public.meal_plans (user_id, date);
CREATE INDEX IF NOT EXISTS meal_plans_recipe_idx ON public.meal_plans (user_id, recipe_id);

-- Set up RLS (Row Level Security)
ALTER TABLE public.meal_plans ENABLE ROW LEVEL SECURITY;

-- Policy for select: users can only view their own meal plans
CREATE POLICY meal_plans_select_policy ON public.meal_plans
  FOR SELECT USING (auth.uid() = user_id);

-- Policy for insert: users can only insert their own meal plans
CREATE POLICY meal_plans_insert_policy ON public.meal_plans
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for update: users can only update their own meal plans
CREATE POLICY meal_plans_update_policy ON public.meal_plans
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy for delete: users can only delete their own meal plans
CREATE POLICY meal_plans_delete_policy ON public.meal_plans
  FOR DELETE USING (auth.uid() = user_id); 