fs = require("fs");
const path = require("path");

/**
 * make new folder named generated
 */

const newImageDirectory = __dirname + path.sep + "generated" + path.sep;

/**
 * how many you want to create
 */
const numToCreate = 10;

let image = ["1.jpg", "2.jpg", "3.jpg", "4.jpg", "5.jpg", "6.jpg", "7.jpg", "8.jpg", "9.jpg"];

for (let i = 0; i < numToCreate; i++) {
  const selectedImage = image[Math.floor(Math.random() * image.length)];
  const copiedImage = __dirname + path.sep + selectedImage;
  const newImage = newImageDirectory + i + ".jpg";
  fs.copyFileSync(copiedImage, newImage);
}
