package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

var router *gin.Engine

func main() {
	//Set the router as the default one provided by Gin
	router = gin.Default()
	//Load Template
	router.LoadHTMLGlob("templates/*")

	//Initialize the routes
	initializeRoutes()

	//Start serving the application
	router.Run()
}

// Render one of HTML, JSON or CSV based on the 'Accept' header of the request
// If the header doesn't specify this, HTML is rendered, provided that
// the templates name is present
func render(c *gin.Context, data gin.H, templateName string) {

	switch c.Request.Header.Get("Accept") {
	case "application/json":
		//Respond with JSON
		c.JSON(http.StatusOK, data["payload"])
	case "application/xml":
		//Respond with XML
		c.XML(http.StatusOK, data["payload"])
	default:
		//Repond with HTML
		c.HTML(http.StatusOK, templateName, data)
	}
}
