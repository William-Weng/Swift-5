// [William-Weng/Nodejs](https://github.com/William-Weng/Nodejs/blob/master/HelloWorld/07_Upload.js)
// [[Mac系統] 清除系統上被佔用的Port — 1010Code](https://andy6804tw.github.io/2018/02/28/kill-port-macos/)
// [[筆記] 使用 Multer 實作大頭貼上傳(Part 1)](https://medium.com/麥克的半路出家筆記/筆記-使用-multer-實作大頭貼上傳-ee5bf1683113)

const FormInputField = 'Picture'
const ImageFolder = './uploads'
const MaxUploadCount = 3
const Port = 3000

let express = require('express')
let multer = require('multer')
let app = express()

let storage = multer.diskStorage({
  destination: (request, file, callback) => { callback(null, ImageFolder) },
  filename: (request, file, callback) => { callback(null, Date.now() + '_' + file.originalname) },
})

let upload = multer({ storage : storage }).array(FormInputField, MaxUploadCount)

app.get('/', (request, response) => {
  response.sendFile(__dirname + "/index.html")
})

app.post('/api/photo', (request, response) => {

  upload(request, response, function(error) {
    if(error) { return response.end(`{"error" : ${error}}`) }
    response.end(`{'Success': ${true} }`)
  })
})

app.listen(Port, () => {
    console.log(`Working on port ${Port}`)
})
