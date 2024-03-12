# xc-api-validation-presence
Do your F5 Distributed Cloud HTTP Load Balancers have an API Validation configured? This script finds out.

This is a BASH shell script written to query all the namespaces in an XC tenant, pull the HTTP LB configs, and reduce the JSON objects down to minimum objects required to determine the API validation state of each LB in a tenant.

To use this script without human interaction it is necessary to define environmental variables for the tenant name (TENANT) as well as an API token (APITOKEN), otherwise this script will ask for them.

export TENANT=[TENANT SUBDOMAIN VALUE]
export APITOKEN=[APITOKEN VALUE CREATED IN THE XC CONSOLE]

The tenant subdomain is the where you log in to the console. Ex. [MY-ORGANIZATION].console.ves.volterra.io

The APIToken is a credential that is generated in the console (or via API call). For more information please visit https://docs.cloud.f5.com/docs-v2/administration/how-tos/user-mgmt/Credentials

