require 'savon'
require 'digest'

client = Savon.client do
  wsdl "https://webapi.allegro.pl/service.php?wsdl"
end

cnf = YAML.load_file('config.yml')

haslo  = Digest::SHA256.base64digest cnf['password']

local_versioon_response = client.call(:do_query_sys_status, message: {'sysvar' => 1, 
                                                                      'countryId' => 1, 
                                                                      'webapiKey' => cnf['webapikey']})

login_response = client.call(:do_login_enc, message: { 'userLogin' => cnf['user'], 
                                                       'userHashPassword' => haslo,
                                                       'countryCode' => 1, 'webapiKey' => cnf['webapikey'],
                                                       'localVersion' => local_versioon_response.hash[:envelope][:body][:do_query_sys_status_response][:ver_key] })

search_response = client.call(:do_search, message: { 'sessionHandle' => login_response.hash[:envelope][:body][:do_login_enc_response][:session_handle_part],
                                                     'searchQuery' => { 'searchString' => 'Niezwykłe liczby fibonacciego',
                                                                        'searchOptions' => 8,
                                                                        'searchOrder' => 4,
                                                                        #Using searchLimit parameter we dont have guarantee that the offert will be the best
                                                                        'searchLimit' => 10
                                                                      } 
                                                   }
                             )

puts search_response.hash[:envelope][:body][:do_search_response][:search_array][:item].inspect
