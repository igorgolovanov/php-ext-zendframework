
#ifdef HAVE_CONFIG_H
#include "../../../ext_config.h"
#endif

#include <php.h>
#include "../../../php_ext.h"
#include "../../../ext.h"

#include <Zend/zend_operators.h>
#include <Zend/zend_exceptions.h>
#include <Zend/zend_interfaces.h>

#include "kernel/main.h"


/*

This file is part of the php-ext-zendframework package.

For the full copyright and license information, please view the LICENSE
file that was distributed with this source code.

*/
/**
 * Invalid callback exception
 */
ZEPHIR_INIT_CLASS(ZendFramework_EventManager_Exception_InvalidCallbackException) {

	ZEPHIR_REGISTER_CLASS_EX(Zend\\EventManager\\Exception, InvalidCallbackException, zendframework, eventmanager_exception_invalidcallbackexception, zendframework_eventmanager_exception_domainexception_ce, NULL, 0);

	return SUCCESS;

}

