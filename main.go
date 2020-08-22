package main

import (
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"strings"

	rice "github.com/GeertJohan/go.rice"
)

var viewBox *rice.Box

// var resourceBox *rice.Box

func main() {
	// 相对于的执行文件的地址
	box, err := rice.FindBox("view")
	if err != nil {
		log.Fatal("rice FindBox view error: ", err)
	}
	viewBox = box

	// box, err = rice.FindBox("static")
	// if err != nil {
	// 	log.Fatal("rice FindBox static error: ", err)
	// }
	// resourceBox = box

	mux := http.NewServeMux()
	// &myHandler{} 空的字面量来初始化一个 myHandler 结构体变量，并获取结构体变量的地址
	// 第二个参数 handler 是一个结构体指针，实现了 http.Handler
	mux.Handle("/", &myHandler{})
	// 第二个参数 handler 是一个函数
	mux.HandleFunc("/hello", sayHelloName)
	mux.HandleFunc("/login", login)

	// 获取当前工作目录
	// wd, err := os.Getwd()
	// if err != nil {
	// 	log.Fatal("Getwd error: ", err)
	// }
	// 创建一个静态文件服务器，http.Dir() 根据相对路径返回一个绝对路径
	// mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir(wd+"/static/"))))

	// MustFindBox 出错直接 panic
	mux.Handle("/static/", http.StripPrefix("/static/", http.FileServer(rice.MustFindBox("static").HTTPBox())))

	err = http.ListenAndServe(":9090", mux)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}

type myHandler struct{}

// 实现 http.Handler
func (*myHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Welcome to Mars! current url: "+r.URL.String())
}

func login(w http.ResponseWriter, r *http.Request) {
	fmt.Println("method:", r.Method) //获取请求的方法
	if r.Method == "GET" {
		// 从目录 Box 读取文件
		str, err := viewBox.String("login.html")
		if err != nil {
			println(err.Error())
			return
		}
		log.Println("login")
		t, _ := template.New("tpl").Parse(str)
		// t, _ := template.ParseFiles("login.html")
		t.Execute(w, "login")
	} else {
		//请求的是登陆数据，那么执行登陆的逻辑判断
		r.ParseForm()
		fmt.Println("username:", r.FormValue("username"))
		fmt.Println("password:", r.FormValue("password"))
		fmt.Fprintf(w, "login success\n")
		fmt.Fprintf(w, r.FormValue("username")+" "+r.FormValue("password"))
	}
}

func sayHelloName(w http.ResponseWriter, r *http.Request) {
	r.ParseForm() // 解析参数，默认是不会解析的，表单提交或者url传值
	fmt.Println(r.Form)
	fmt.Println("path", r.URL.Path)
	fmt.Println("scheme", r.URL.Scheme)
	// r.Form["name"] 是个数组，因为可能有多个相同的字段，http://localhost:9090/hello?id=3&name=allen_ge&name=king
	fmt.Println(r.Form["name"])
	for k, v := range r.Form {
		fmt.Println("key:", k)
		fmt.Println("val:", strings.Join(v, " "))
	}
	if r.Form["name"] != nil {
		// io.WriteString(w, "Hello "+r.Form["name"][0])
		fmt.Fprintf(w, "Hello "+r.Form["name"][0])
	} else {
		fmt.Fprintf(w, "Hello")
	}
}
