"""
Created on 2022-08-25

@author: Zahra Karim-Aghaloo

Least Trimmed Square fit between two given images (ref: "Computing LTS Regression for Large Data Sets" ROUSSEEUW 2006)
"""

import argparse
import sys
import numpy as np
import nibabel as nib
import os
import warnings


def arguments(argv):
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                     description='Run LTS for intensity normalization')

    parser.add_argument("--input",
                        help='image to be normalized')
    parser.add_argument("--ref",
                        help='reference image for normalization')
    parser.add_argument("--mask",
                        help='data within the given mask are used for normalization')
    parser.add_argument("--output",
                        help='full path for the output')

    return parser.parse_args(argv)


def lts(src, ref, deg=1):
    # warnings.simplefilter('ignore', np.RankWarning)

    # "Computing LTS Regression for Large Data Sets" ROUSSEEUW 2006

    h = int(src.size * 0.75)  # take 75% (instead of (n+p+1)/2 - as suggested in the paper)
    m = 1000  # Number of random starting points
    nbest = 10  # number of starting fits to use
    s_starting_subset = 10 + deg  # size of starting subset
    nmax_iter = 200
    tolerance = 1e-6
    fit_partial_c = np.empty((m, deg + 1))
    res_sq_partial_c = np.empty(m)

    print("drawing {} random starting points and doing partial C-step (up to H_3), " \
          "repeating it for {} times and " \
          "recording the fit and sum-of-res in each time.".format(s_starting_subset, m))

    for j in range(m):  # Draw m random starting points TODO: easy to parallelize
        w = np.random.choice(src.size, s_starting_subset, replace=False)
        fit = np.polyfit(src[w], ref[w], deg=deg)  # find a solution for very small subset

        for k in range(2):  # Run C-steps up to H_3
            res = (np.polyval(fit, src) - ref)
            good = np.argsort(np.abs(res))[:h]  # Fit the h points with smallest errors
            fit = np.polyfit(src[good], ref[good], deg=deg)
            res_sq = np.sum((np.polyval(fit, src[good]) - ref[good]) ** 2)

        fit_partial_c[j, :] = fit
        res_sq_partial_c[j] = res_sq

        # self.logger.debug("primary fit {}: average residual per sample (sqrt(res_sq/h): {}"
        #                   .format(j, np.sqrt(res_sq/h)))

    # Perform full C-steps only for the 10 best results
    w = np.argsort(res_sq_partial_c)
    res_sq = np.inf
    fit = (1, 0)  # (slope, intercept) identity map - if no other good fit is found
    print("selecting {} best fits of the previous {} primary fits, to do ful C-step.".format(nbest, m))

    for j in range(nbest):
        fit_i = fit_partial_c[w[j], :]
        print("doing full C-step for fit number {}: {}".format(j, repr(fit_i)))

        for i in range(nmax_iter):  # Run C-steps to convergence,
            fit_old = fit_i
            res = (np.polyval(fit_i, src) - ref)
            good_i = np.argsort(np.abs(res))[:h]  # get the indices of h points with smallest errors
            fit_i = np.polyfit(src[good_i], ref[good_i], deg=deg)  # Fit the h points with smallest errors
            res_sq_i = np.sum((np.polyval(fit_i, src[good_i]) - ref[good_i]) ** 2)
            print('iter {}: average residual per sample (sqrt(res_sq/h): {}'.format(j, np.sqrt(res_sq_i/h)))
            # print("{} - {}".format(i,np.sqrt(chi1_sq)))
            if np.allclose(fit_old, fit_i, atol=tolerance, rtol=1e-5):
                print('C-step converged for fit number {}'.format(j))
                break

        if i == (nmax_iter - 1):
            print("C-step didn't converge for fit number {}".format(j))
            # raise Exception

        print("final residual (avg-res-per-sample) for fit "
              "number {}: {}, fit is: {}".format(j, np.sqrt(res_sq_i / h), repr(fit_i)))

        if res_sq > res_sq_i:
            fit = fit_i  # Save best solution
            good = good_i
            res_sq = res_sq_i

    print("Final selected fit is: {}".format(repr(fit)))
    print("Final residual (avg-res-per-sample) for selected fit is: {} ".format(np.sqrt(res_sq / h)))

    # mask of good examples:
    mask = np.zeros_like(src, dtype=bool)
    mask[good] = True
    return fit


def main(argv=sys.argv[1:]):
    args = arguments(argv)
    input = nib.load(args.input)
    reference = nib.load(args.ref)
    mask = nib.load(args.mask)
    outname = args.output

    if os.path.isfile(outname):
        print ('output already exists! {}'.format(outname))
        return

    src = input.get_data().astype(float)
    ref = reference.get_data().astype(float)
    msk = mask.get_data().astype(float)

    src_flat = np.ravel(src[msk > 0.5])
    ref_flat = np.ravel(ref[msk > 0.5])

    fit = lts(src_flat, ref_flat)
    print('final fit is {}'.format(fit))

    bias = fit[1]
    slope = fit[0]

    out = bias + slope * src
    # out[msk < 0.5] = 0

    img2 = nib.Nifti1Image(out,
                           input.affine,
                           header=input.header,
                           extra=input.extra,
                           file_map=input.file_map)

    nib.save(img2, outname)


if __name__ == "__main__":
    main()