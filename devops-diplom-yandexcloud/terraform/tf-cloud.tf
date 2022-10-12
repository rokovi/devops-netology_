terraform {
  cloud {
    organization = "rokovi-corp"

    workspaces {
      name = "stage"
    }
  }
}