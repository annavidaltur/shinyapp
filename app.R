library(shiny)
library(base64enc)
library(imager)


ui <- fluidPage(
  fileInput("myFile", "Upload image", accept = c("image/png", "image/jpg")),
  h2('Image uploaded:'),
  uiOutput("image"),
  
  h2('Palette:'),
  plotOutput("plotPalette"),
)

server <- function(input, output){
  # Copy image uploaded to www/
  observeEvent(input$myFile, {
    inFile <- input$myFile
    if (is.null(inFile))
      return()
    file.copy(inFile$datapath, file.path("www", inFile$name) )
  })
  
  # Show image uploaded
  base64 <- reactive({
    inFile <- input[["myFile"]]
    if(!is.null(inFile)){
      dataURI(file = inFile$datapath, mime = "image/png")
    }
  })
  
  # Show image uploaded
  output[["image"]] <- renderUI({
    if(!is.null(base64())){
      tags$div(
        tags$img(src= base64(), width="100%"),
        style = "width: 400px;"
      )
    }
  })
  
  # Create palette
  output$plotPalette <- renderImage({
    # A temp file to save the output. It will be deleted after renderImage
    # sends it, because deleteFile=TRUE.
    outfile <- tempfile(fileext='.png')
    
    # Generate a png
    png(outfile, width=400, height=400)
    plot(boats)
    dev.off()
    
    # Return a list
    list(src = outfile,
         alt = "This is alternate text")
  }, deleteFile = FALSE)
}

shinyApp(ui, server)