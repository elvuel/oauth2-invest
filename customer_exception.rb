class CustomerException < Exception

  @@exception_code = {
      invalid_client_id: 001, # response:   {"error"=>"invalid_client", "error_description"=>"Client ID and client secret do not match.", "state"=>""}
      client_id_missing: 002,
      invalid_authentication_code: 003, # response: Invalid authorization request
      response_type_incorrect: 004,
      invalid_redirect_uri: 005 # [should be /oauth/callback but is /auth/callback] response to redirect : http://localhost:9191/auth/callback?error=redirect_uri_mismatch&error_description=Must+use+the+same+redirect+URI+you+registered+with+us.&state=
  }

end

__END__
Optional params:
  Flow:
    1. [Obtaining End-User Authorization] request authentication code, if no exceptions raises then redirect to self location with status 303[means 'see other']
        *redirect_uri => be validated with server side the client's registered redirect_uri

        *response_type  => code: raise UnsupportedResponseTypeError unless options.authorization_types.include?(response_type)

        *scope =>
            requested_scope = Utils.normalize_scope(request.GET["scope"])
            allowed_scope = client.scope
            raise InvalidScopeError unless (requested_scope - allowed_scope).empty?

        *state =>
            both   for  code:auth_request = AuthRequest.create(client, requested_scope, redirect_uri.to_s, response_type, state)
                also for Exception rescue detail

    2. get authentication code successfully

        *authentication =>  is passed by last 303 redirect request, with this param should fetch the right client or not.

        *state =>
              only for Exception rescue detail
