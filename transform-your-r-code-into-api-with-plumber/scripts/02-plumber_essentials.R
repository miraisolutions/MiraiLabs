# plumber.R

#* Hello world
#* @get /hello
function(){
  "Hello World"
}

#* Hello world, html output
#* @html
#* @get /hello/html
function(){
  "Hello World"
}

#* Plot a histogram
#* @png
#* @get /plot
function(){
  rand <- rnorm(1000)
  hist(rand)
}

#* Echo back the input msg
#* @param msg The message to echo
#* @get /echo
function(msg=""){
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot out data from the iris dataset. Dynamic route (e.g. 'setosa', 'virginica')
#* @param species Filter the data to get only this species (e.g. 'setosa')
#* @get /iris/<species>
#* @png
function(species){
  # Throw an ugly error if the species is not valid
  if (!is.element(species, iris$Species)) {
    msg <- sprintf("%s is not a valid species of dataset iris. Valid values are: %s",
                   species, paste0(levels(iris$Species), collapse = ", "))
    stop(msg)
  }
  # Plot the requested species
  iris_subset <- subset(iris, Species == species)
  plot(iris_subset$Sepal.Length, iris_subset$Petal.Length,
       main = paste0("Species: ", species), xlab = "Sepal.Length", ylab = "Petal.Length")
}


#* Return the sum of two numbers. Typed dynamic route.
#* @param a The first number to add
#* @param b The second number to add
#* @get /sum/<a:numeric>/<b:numeric>
function(a, b){
  a + b
}

# #* Notice the notation below provides info to SwaggerUI about the type but does not enforce it.
# #* @param a:numeric The first number to add
# #* @param b:numeric The second number to add
# #* @get /sum1/
# function(a, b){
#   a + b
# }

