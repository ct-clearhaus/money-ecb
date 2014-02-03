money-ecb
==========

.. image:: https://travis-ci.org/ct-clearhaus/money-ecb.png?branch=master
    :target: https://travis-ci.org/ct-clearhaus/money-ecb


Introduction
------------

This gem is a RubyMoney bank that can exchange ``Money`` using rates from the
ECB (European Central Bank).


Installation
------------

.. code-block:: sh

    gem install money-ecb

Dependencies
............

- RubyMoney's ``money`` gem
- ``rubyzip`` gem


Example
-------

Using ``money`` and ``monetize``:

.. code-block:: ruby

    require 'money'
    require 'money/bank/ecb'
    require 'monetize'

    Money.default_bank = Money::Bank::ECB.new('/tmp/ecb-fxr.cache')

    puts '1 EUR'.to_money.exchange_to(:USD)

If ``/tmp/ecb-fxr.cache`` is a valid CSV file with exchange rates, the rates
will be used for conversion. If the file does not exist, new rates will be
downloaded from the European Central Bank and stored in the file. To update the
cache,

.. code-block:: ruby

    Money.default_bank.update


Rounding
--------

By default, ``Money::Bank``'s will truncate. If you prefer to
round, ``#exchange_with`` will accept a block that will be yielded; that block
you can use for rounding (and other purposes) when exchanging:

.. code-block:: ruby

    ecb = Money::Bank::ECB.new('/tmp/ecb-fxr.cache')
    ecb.exchange_with('1 EUR'.to_money, :USD) {|x| x.round}


Contribute
----------

* `Fork <https://github.com/ct-clearhaus/money-ecb/fork>`_
* Clone
* ``bundle install``
* ``bundle exec rake test``
* Make your changes
* Test your changes
* Create a Pull Request
* Celebrate!

