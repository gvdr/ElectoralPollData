get_names_parties <- function(html){
    party_names <- html %>%
    html_node("tr")  %>%
    html_nodes("th") %>%
    map_chr(extract_name_from_title)

    party_names <- party_names[nzchar(party_names)]

    return(party_names)
}

extract_name_from_title <- function(html){
    name_s <- html %>%
        html_nodes("a") %>%
        html_attr("href") %>%
        str_remove("/wiki/")
    
    L <- length(name_s)

    if(L > 1){
        print(name_s)
    }
        
    name <- name_s %>%
    paste(collapse = " ")

    if(L > 1){
        print(name)
    }

    return(name)

}

get_tables <- function(url, head_n){
tables <- url %>%
    read_html() %>%
    html_nodes(".wikitable") %>%
    html_table(header = NA,
    na.strings = c("?","–", "—", ""))  %>%
    head(head_n)

    return(tables)
}

get_parties <- function(url, head_n){
   parties <- url %>%
    read_html() %>%
    html_nodes(".wikitable") %>%
    head(head_n) %>%
    map(get_names_parties) %>%
    map(str_remove,"/wiki/")

    return(parties)
}

set_raw_names <- function(head_n, rawtabs, parts){
    for (i in 1:head_n) {
    names(rawtabs[[i]]) <- c("Firm","Date","Sample","Turnout",parts[[i]],"Lead")
    rawtabs[[i]] <- rawtabs[[i]] %>% mutate_at(parts[[i]],as.character)
    }

    return(rawtabs)
}


get_percentage <- function(myvalue, pattern_low_date = "([0-9]+.\\d)–", pattern_up_date = "–([0-9]+.\\d)", pattern_one_date = "[0-9]+.\\d") {
    if(is.na(myvalue)){return(NA)}
    if(!stri_detect(myvalue, fixed = ".")){return(NA)}
    if (str_detect(myvalue, "–")) {
        low <- myvalue %>% str_extract(pattern_low_date, group = 1) %>% as.numeric
        upp <- myvalue %>% str_extract(pattern_up_date, group = 1) %>% as.numeric
        mid <- (low+upp)/2
        return(mid)
    } else {
        mid <- myvalue %>% str_extract(pattern_one_date) %>% as.numeric
        return(mid)
    }
}

get_date <- function(myvalue, pattern = "\\d{1,2}\\s\\w{3}$"){
    myvalue %>% str_extract(pattern)
}

clean_up_names <- function(names){
    names_clean <- names %>%
    str_replace_all("[^[a-zA-Z]?]", "") %>%
    tolower() %>%
    stringi::stri_trans_general("Latin-ASCII")

    return(names_clean)
}

