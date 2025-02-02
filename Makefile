generate:
	buf generate

lint:
	buf lint
	buf breaking --against 'https://github.com/abdybaevae/url-shortener.git#branch=master'

BUF_VERSION:=0.40.0

install:
	go install \
		google.golang.org/protobuf/cmd/protoc-gen-go \
		google.golang.org/grpc/cmd/protoc-gen-go-grpc \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2
	curl -sSL \
    	"https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-$(shell uname -s)-$(shell uname -m)" \
    	-o "$(shell go env GOPATH)/bin/buf" && \
  	chmod +x "$(shell go env GOPATH)/bin/buf"

tests:
	reflex -c reflex-test.conf

MOCKS_DESTINATION=mocks
.PHONY: mocks
mocks: proto/links_grpc.pb.go pkg/services/algo/type.go pkg/repos/algo/type.go pkg/services/key/type.go pkg/repos/key/type.go pkg/services/link/type.go pkg/repos/link/type.go pkg/services/number/type.go pkg/repos/number/type.go
	@echo "Generating mocks..."
	@rm -rf $(MOCKS_DESTINATION)
	@for file in $^; do mockgen -source=$$file -destination=$(MOCKS_DESTINATION)/$$file; done

DB_URL=postgres://cifer@localhost:5432/url_shortener?sslmode=disable

.PHONY: run-migrations 
run-migrations: 
	 migrate -database ${DB_URL} -path db/migrations up


dev: run-migrations
	reflex -c reflex-dev.conf
	
# .PHONY: migrate 
# migrate: 

# migrate create -ext sql -dir db/migrations -seq create_links_table
# migrate -database "postgres://cifer@localhost:5432/url_shortener?sslmode=disable" -path db/migrations up 3

