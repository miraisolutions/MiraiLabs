#exercise 01 with solutions
library(plumber)

# 1) ----
# GET current date and time (Sys.time())

#* Return Date time
#* @get /DateTime
function(){
  Sys.time()
}

# 2) ----
# Decorate a function that would return the sentence “Today is … “ based on the input day.

#* Return Today
#* @param day text input provided by the user
#* @get /Today
function(day){
  paste0("Today is ", day)
}

# 3) ----
# Consider the function to return the predicted miles per gallon for a given cylinder:
#  function(cyl) {
#    predict(lm(mpg ~ cyl, data = mtcars), data.frame(cyl = cyl))
#  }
# Make a GET endpoint to serve the model (hint: what type should cyl have for this to work?)

#* Return mpg per cyl
#* @param cyl number of cylinders
#* @get  /v1/predict_mpg
 function(cyl) {
   predict(lm(mpg ~ cyl, data = mtcars), data.frame(cyl = as.numeric(cyl)))
 }

#* Return mpg per cyl
#* @param cyl:numeric number of cylinders
#* @get  /v2/predict_mpg
function(cyl) {
  predict(lm(mpg ~ cyl, data = mtcars), data.frame(cyl = cyl))
}

#* Return mpg per cyl
#* @param cyl number of cylinders
#* @get  /v3/predict_mpg/<cyl:numeric>
function(cyl) {
  predict(lm(mpg ~ cyl, data = mtcars), data.frame(cyl = cyl))
}