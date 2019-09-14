const express = require("express");
const request = require("request");
const cheerio = require("cheerio");

const app = express();

const skipSymbol = (string, symbol) =>
  string.substring(string.indexOf(symbol) + 1);

const wrapSymbol = (string, symbol) =>
  string.substring(0, string.indexOf(symbol));

const requestPageData = id =>
  new Promise((resolve, reject) => {
    request(
      {
        url: `https://www.facebook.com/pg/${id}/about/?ref=page_internal`,
        headers: {
          "User-Agent":
            "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
        }
      },
      (error, response, jsx) => {
        if (!error) {
          const dom = cheerio.load(jsx);
          const html = dom.html();

          const genreExclusive = html
            .substring(html.indexOf("Genre"))
            .substring(0, 300);
          const genreText = wrapSymbol(
            skipSymbol(skipSymbol(genreExclusive, ">"), ">"),
            "<"
          );

          const categoryExlusive = html
            .substring(
              html.indexOf('16px;color: #385898" id="u_0_r" data-nt="FB:TEXT4"')
            )
            .substring(0, 300);

          const categoryText = wrapSymbol(
            skipSymbol(
              skipSymbol(
                skipSymbol(skipSymbol(categoryExlusive, ">"), ">"),
                ">"
              ),
              ">"
            ),
            "<"
          );
          resolve({ genreText, categoryText });
        }
        reject();
      }
    );
  });

app.get("/pageData/:id", async (req, res) => {
  const { id } = req.params;
  const pageData = await requestPageData(id);
  return res.status(200).json(pageData);
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Listening to port ${port}`));
