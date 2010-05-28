%% -----------------------------------------------------------------------------
%%
%% Hamcrest Erlang.
%%
%% Copyright (c) 2010 Tim Watson (watson.timothy@gmail.com)
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy
%% of this software and associated documentation files (the "Software"), to deal
%% in the Software without restriction, including without limitation the rights
%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the Software is
%% furnished to do so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in
%% all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%% THE SOFTWARE.
%% -----------------------------------------------------------------------------
%% @author Tim Watson <watson.timothy@gmail.com>
%% @copyright 2010 Tim Watson.
%% @doc Hamcrest API
%% @reference See <a href="http://code.google.com/p/hamcrest/">Hamcrest</a>
%% for more information.
%% -----------------------------------------------------------------------------

-module(hamcrest).

-include("hamcrest_internal.hrl").

-export([assert_that/2]).

assert_that(Value, #'hamcrest.matchspec'{ matcher=MatchFunc }=MatchSpec) ->
    try assert_that(Value, MatchFunc)
    catch
        error:{assertion_failed,_} ->
            erlang:error({assertion_failed, describe(MatchSpec, Value)})
    end;
assert_that(Value, MatchSpec) when is_function(MatchSpec, 1) ->
    case MatchSpec(Value) of
      false -> erlang:error({assertion_failed, default_describe(Value)});
      _ -> true
    end.

default_describe(Value) ->
    describe(fun(X) ->
                lists:flatten(io_lib:format("unexpected value ~p", [X]))
             end, undefined, Value).

describe(#'hamcrest.matchspec'{ desc=Desc, expected=Expected }, Actual) ->
    describe(Desc, Expected, Actual).

describe(Desc, Expected, Actual) when is_function(Desc, 2) ->
    Desc(Expected, Actual);
describe(Desc, _, Actual) when is_function(Desc, 1) ->
    Desc(Actual);
describe(Desc, Expected, Actual) when is_list(Desc) ->
    io_lib:format(Desc, [Expected, Actual]).
