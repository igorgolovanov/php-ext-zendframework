
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


/**
 * Extension not loaded exception
 */
ZEPHIR_INIT_CLASS(ZendFramework_Stdlib_Exception_ExtensionNotLoadedException) {

	ZEPHIR_REGISTER_CLASS_EX(Zend\\Stdlib\\Exception, ExtensionNotLoadedException, zendframework, stdlib_exception_extensionnotloadedexception, zendframework_stdlib_exception_runtimeexception_ce, NULL, 0);

	return SUCCESS;

}
