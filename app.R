library(shiny)

# Define UI ----
ui <- fluidPage(
  titlePanel(h1("Paleta de colores")),
  
  sidebarLayout(
    sidebarPanel(h2("Subir imagen", align = "center"),
                 fileInput("file", h3("Subir imagen")),
                 submitButton("Analizar"),
                ),
    mainPanel(h2("Resultado", align = "center"),
              img(src = "image.jpg", width=300)
              )
  )
)

# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)