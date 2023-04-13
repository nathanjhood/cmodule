/*******************************************************************************
 *
 * @file stoneydsp_math_constants.h
 * @author Nathan J. Hood (nathanjhood@googlemail.com)
 * @version 1.0.0.1
 * @date 2022-09-02
 *
 * @copyright Copyright (c) 2022 @StoneyDSP
 *
 *******************************************************************************
*/

// From <corecrt_math_defines.h>...
// Definitions of useful mathematical constants
//
// Define _USE_MATH_DEFINES before including <math.h> to expose these macro
// definitions for common math constants.  These are placed under an #ifdef
// since these commonly-defined names are not part of the C or C++ standards
// #define M_E        2.71828182845904523536   // e
// #define M_LOG2E    1.44269504088896340736   // log2(e)
// #define M_LOG10E   0.434294481903251827651  // log10(e)
// #define M_LN2      0.693147180559945309417  // ln(2)
// #define M_LN10     2.30258509299404568402   // ln(10)
// #define M_PI       3.14159265358979323846   // pi
// #define M_PI_2     1.57079632679489661923   // pi/2
// #define M_PI_4     0.785398163397448309616  // pi/4
// #define M_1_PI     0.318309886183790671538  // 1/pi
// #define M_2_PI     0.636619772367581343076  // 2/pi
// #define M_2_SQRTPI 1.12837916709551257390   // 2/sqrt(pi)
// #define M_SQRT2    1.41421356237309504880   // sqrt(2)
// #define M_SQRT1_2  0.707106781186547524401  // 1/sqrt(2)


#pragma once

#ifndef MATH_CONSTANTS_H_INCLUDED
#define MATH_CONSTANTS_H_INCLUDED

namespace stoneydsp
{

template<typename T>
struct MathConstants
{
    /** A predefined value for Zero */
    static constexpr T zero = static_cast<T> (0.0L);

    /** A predefined value for One */
    static constexpr T one = static_cast<T> (1.0L);

    /** A predefined value for Two */
    static constexpr T two = static_cast<T> (2.0L);

    /** A predefined value for minus One */
    static constexpr T minusOne = static_cast<T> (-1.0L);

    /** A predefined value for minus Two */
    static constexpr T minusTwo = static_cast<T> (-2.0L);

    /** A predefined value for one third of one */
    static constexpr T oneThird = static_cast<T> (1.0L / 3.0L);

    /** A predefined value for two thirds of one */
    static constexpr T twoThirds = static_cast<T> (2.0L / 3.0L);

    /** A predefined value for pi */
    static constexpr T pi = static_cast<T> (3.14159265358979323846L);

    /** A predefined value for 2pi */
    static constexpr T twoPi = static_cast<T> (2.0L * 3.14159265358979323846L);

    /** A predefined value for pi/2 */
    static constexpr T piDivTwo = static_cast<T> (1.57079632679489661923L);

    /** A predefined value for Euler's number (e) */
    static constexpr T euler = static_cast<T> (2.71828182845904523536L);

    /** A predefined value for tau */
    static constexpr T tau = static_cast<T> (1.0L - (1.0L / 2.71828182845904523536L));

    /** A predefined value for sqrt(2) */
    static constexpr T sqrtTwo = static_cast<T> (1.41421356237309504880L);

    /** A predefined value for 1/sqrt(2) */
    static constexpr T OneDivSqrtTwo = static_cast<T> (0.707106781186547524401L);

    /** A predefined value for 2/sqrt(pi). */
    static constexpr T twoDivSqrtPi = static_cast<T> (1.12837916709551257390L);

    /** A predefined value for 1/pi */
    static constexpr T oneDivPi = static_cast<T> (0.318309886183790671538L);

    /** A predefined value for 2/pi */
    static constexpr T twoDivPi = static_cast<T> (0.636619772367581343076L);

    /** A predefined value for log2(e) */
    static constexpr T logTwoE = static_cast<T> (1.44269504088896340736L);

    /** A predefined value for log10(e) */
    static constexpr T logTenE = static_cast<T> (0.434294481903251827651L);

    /** A predefined value for ln(2) */
    static constexpr T linTwo = static_cast<T> (0.693147180559945309417L);

    /** A predefined value for ln(10) */
    static constexpr T linTen = static_cast<T> (2.30258509299404568402L);
};

} //namespace stoneydsp

#endif // MATH_CONSTANTS_H_INCLUDED
