.PHONY: test

iex: 
	source .env.dev && iex -S mix

install:
	mix deps.get

test:
	mix test

test.wip:
	mix test --only wip

test.watch:
	mix test.watch

test.wip.watch:
	mix test.watch --only wip

test.wip.iex:
	iex -S mix test --only wip 

ci.test:
	@make install
	@make test
	MIX_ENV=dev mix credo list --strict --format=oneline
	MIX_ENV=test mix coveralls
	MIX_ENV=dev mix dialyzer --format short