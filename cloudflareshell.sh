#!/bin/sh

if [[ -z $@ ]]
  then
    printf "\nUsage:
    $0 <account-alias> -> Get all record names, IDs and content
    $0 <account-alias> domain_records -> Get all domain records in full
    $0 <account-alias> record_id <name> -> find record id from host name
    $0 <account-alias> update_record <name> <IP>
    $0 <account-alias> new_record <name> <IP>
    $0 <account-alias> delete_record <name>

    <account-alias> is one of pp or jj
    <name> is the NON-fully-qualified name

example:
    $0 jj record_id host.cloudflaredomain.com\n\n"
  exit
fi

. credentials

function domain_records() {
curl -k https://www.cloudflare.com/api_json.html \
  -d "tkn=$cfkey" \
  -d "email=$email" \
  -d "z=$zone" \
  -d 'a=rec_load_all' 2>/dev/null |jq "."
}

function update_record () {
curl -k https://www.cloudflare.com/api_json.html \
  -d "tkn=$cfkey" \
  -d "email=$email" \
  -d "z=$zone" \
  -d 'ttl=1' \
  -d 'a=rec_edit' \
  -d "id=$(record_id $1)" \
  -d 'type=A' \
  -d "name=$1" \
  -d "content=$2"
}

function new_record () {
curl https://www.cloudflare.com/api_json.html \
  -d "tkn=$cfkey" \
  -d "email=$email" \
  -d "z=$zone" \
  -d 'ttl=1' \
  -d 'a=rec_new' \
  -d 'type=A' \
  -d "name=$1" \
  -d "content=$2"
}

function delete_record () {
curl https://www.cloudflare.com/api_json.html \
  -d "tkn=$cfkey" \
  -d "email=$email" \
  -d "z=$zone" \
  -d 'a=rec_delete' \
  -d "id=$(record_id $1)"
}

function record_id () {
domain_records|jq ".response.recs.objs[]|select(.display_name==\"$1\")|.rec_id" -r
}

function record_ids () {
domain_records|jq ".response.recs.objs[]|[.rec_id, .name, .content]|@tsv" -r|sort -k2|column -t
}


$1
${2-record_ids} $3 $4 $5
