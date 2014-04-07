`Refinery::Seeds` provides a DSL for defining Refinery CMS `Page`s and
`PagePart`s to load when seeding (`rake db:seed`). The contents of each
`PagePart` are loaded from templates based on a naming convention, and
`Image`s are loaded and can be referenced in the templates using a helper.

