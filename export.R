
# tryCatch(fs::dir_delete("docs"), error=\(e){})

source("prepare.R")

shinylive::export(
  "app", "docs",
  wasm_packages = TRUE,
  package_cache = TRUE
  )

fs::file_copy("datasets.Rds", "docs", overwrite = TRUE)

rmarkdown::render(
  "landingpage.md",
  rmarkdown::html_document(
    template = "pandoc_template_about.html"
  ),
  output_file="docs/about.html"
) 
