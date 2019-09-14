describe("Page Information Scraper", () => {
  it("should load page", async () => {
    cy.visit(
      `https://www.facebook.com/pg/83711079303/about/?ref=page_internal`
    );

    cy.document()
      .contains("Genre")
      .siblings()
      .invoke("text")
      .then(doc => {
        console.log(doc);
      });

    cy.get("._4bl9")
      .get("._5m_o")
      .invoke("text")
      .then(tag => console.log(tag));
  });
});
