package com.eclecticlogic.stepper.asl

import com.jayway.jsonpath.ReadContext

/**
 * General structure tests.
 */
class TestBasic extends AbstractStateMachineTester {

    def "test simple"() {
        given:
        ReadContext ctx = runProgram('basic.stg', 'simple')

        expect:
        with(ctx) {
            read('$.StartAt') == 'Simple000'
            read('$.States').size() == 2

            read('$..Simple000.Type')[0] == 'Pass'
            read('$..Simple000.Result')[0] == 'Hello World'
            read('$..Simple000.ResultPath')[0] == '$.a'
            read('$..Simple000.Next')[0] == 'Simple001'

            read('$..Simple001.Type')[0] == 'Succeed'
        }
    }


    def "test annotation and state name"() {
        given:
        ReadContext ctx = runProgram('basic.stg', 'annotationName')

        expect:
        with(ctx) {
            read('$.Comment') == 'this is a comment'
            read('$.TimeoutSeconds') == 3600
            read('$.Version') == '1.0'

            read('$.StartAt') == 'AnnotationTest000'
            read('$..AnnotationTest000.Type')[0] == 'Pass'
            read('$..AnnotationTest000.Result')[0] == 5
            read('$..AnnotationTest000.ResultPath')[0] == '$.c'
            read('$..AnnotationTest000.Next')[0] == 'AnnotationTest001'

            read('$..AnnotationTest001.Type')[0] == 'Succeed'
        }
    }


    def "test primitive assignment"() {
        given:
        ReadContext ctx = runProgram('basic.stg', 'assignmentPrimitive')

        when:
        Closure primitiveTest = { key, value, resultVar ->
            verifyAll(ctx) {
                read('$..' + key + '.Type')[0] == 'Pass'
                read('$..' + key + '.Result')[0] == value
                read('$..' + key + '.ResultPath')[0] == '$.' + resultVar
            }
            return true
        }

        then:
        primitiveTest('assignment000', 5.2, 'a')
        primitiveTest('assignment001', 10, 'b')
        primitiveTest('assignment002', 'Hello World', 'c')
        primitiveTest('assignment003', true, 'd')
        primitiveTest('assignment004', false, 'e')
    }

}