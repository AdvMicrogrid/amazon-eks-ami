// Code generated by smithy-go-codegen DO NOT EDIT.

package ec2

import (
	"context"
	"fmt"
	awsmiddleware "github.com/aws/aws-sdk-go-v2/aws/middleware"
	"github.com/aws/aws-sdk-go-v2/service/ec2/types"
	"github.com/aws/smithy-go/middleware"
	smithyhttp "github.com/aws/smithy-go/transport/http"
)

// Associates a CIDR block with your VPC. You can associate a secondary IPv4 CIDR
// block, an Amazon-provided IPv6 CIDR block, or an IPv6 CIDR block from an IPv6
// address pool that you provisioned through bring your own IP addresses ([BYOIP] ).
//
// You must specify one of the following in the request: an IPv4 CIDR block, an
// IPv6 pool, or an Amazon-provided IPv6 CIDR block.
//
// For more information about associating CIDR blocks with your VPC and applicable
// restrictions, see [IP addressing for your VPCs and subnets]in the Amazon VPC User Guide.
//
// [BYOIP]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-byoip.html
// [IP addressing for your VPCs and subnets]: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html
func (c *Client) AssociateVpcCidrBlock(ctx context.Context, params *AssociateVpcCidrBlockInput, optFns ...func(*Options)) (*AssociateVpcCidrBlockOutput, error) {
	if params == nil {
		params = &AssociateVpcCidrBlockInput{}
	}

	result, metadata, err := c.invokeOperation(ctx, "AssociateVpcCidrBlock", params, optFns, c.addOperationAssociateVpcCidrBlockMiddlewares)
	if err != nil {
		return nil, err
	}

	out := result.(*AssociateVpcCidrBlockOutput)
	out.ResultMetadata = metadata
	return out, nil
}

type AssociateVpcCidrBlockInput struct {

	// The ID of the VPC.
	//
	// This member is required.
	VpcId *string

	// Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the
	// VPC. You cannot specify the range of IPv6 addresses or the size of the CIDR
	// block.
	AmazonProvidedIpv6CidrBlock *bool

	// An IPv4 CIDR block to associate with the VPC.
	CidrBlock *string

	// Associate a CIDR allocated from an IPv4 IPAM pool to a VPC. For more
	// information about Amazon VPC IP Address Manager (IPAM), see [What is IPAM?]in the Amazon VPC
	// IPAM User Guide.
	//
	// [What is IPAM?]: https://docs.aws.amazon.com/vpc/latest/ipam/what-is-it-ipam.html
	Ipv4IpamPoolId *string

	// The netmask length of the IPv4 CIDR you would like to associate from an Amazon
	// VPC IP Address Manager (IPAM) pool. For more information about IPAM, see [What is IPAM?]in the
	// Amazon VPC IPAM User Guide.
	//
	// [What is IPAM?]: https://docs.aws.amazon.com/vpc/latest/ipam/what-is-it-ipam.html
	Ipv4NetmaskLength *int32

	// An IPv6 CIDR block from the IPv6 address pool. You must also specify Ipv6Pool
	// in the request.
	//
	// To let Amazon choose the IPv6 CIDR block for you, omit this parameter.
	Ipv6CidrBlock *string

	// The name of the location from which we advertise the IPV6 CIDR block. Use this
	// parameter to limit the CIDR block to this location.
	//
	// You must set AmazonProvidedIpv6CidrBlock to true to use this parameter.
	//
	// You can have one IPv6 CIDR block association per network border group.
	Ipv6CidrBlockNetworkBorderGroup *string

	// Associates a CIDR allocated from an IPv6 IPAM pool to a VPC. For more
	// information about Amazon VPC IP Address Manager (IPAM), see [What is IPAM?]in the Amazon VPC
	// IPAM User Guide.
	//
	// [What is IPAM?]: https://docs.aws.amazon.com/vpc/latest/ipam/what-is-it-ipam.html
	Ipv6IpamPoolId *string

	// The netmask length of the IPv6 CIDR you would like to associate from an Amazon
	// VPC IP Address Manager (IPAM) pool. For more information about IPAM, see [What is IPAM?]in the
	// Amazon VPC IPAM User Guide.
	//
	// [What is IPAM?]: https://docs.aws.amazon.com/vpc/latest/ipam/what-is-it-ipam.html
	Ipv6NetmaskLength *int32

	// The ID of an IPv6 address pool from which to allocate the IPv6 CIDR block.
	Ipv6Pool *string

	noSmithyDocumentSerde
}

type AssociateVpcCidrBlockOutput struct {

	// Information about the IPv4 CIDR block association.
	CidrBlockAssociation *types.VpcCidrBlockAssociation

	// Information about the IPv6 CIDR block association.
	Ipv6CidrBlockAssociation *types.VpcIpv6CidrBlockAssociation

	// The ID of the VPC.
	VpcId *string

	// Metadata pertaining to the operation's result.
	ResultMetadata middleware.Metadata

	noSmithyDocumentSerde
}

func (c *Client) addOperationAssociateVpcCidrBlockMiddlewares(stack *middleware.Stack, options Options) (err error) {
	if err := stack.Serialize.Add(&setOperationInputMiddleware{}, middleware.After); err != nil {
		return err
	}
	err = stack.Serialize.Add(&awsEc2query_serializeOpAssociateVpcCidrBlock{}, middleware.After)
	if err != nil {
		return err
	}
	err = stack.Deserialize.Add(&awsEc2query_deserializeOpAssociateVpcCidrBlock{}, middleware.After)
	if err != nil {
		return err
	}
	if err := addProtocolFinalizerMiddlewares(stack, options, "AssociateVpcCidrBlock"); err != nil {
		return fmt.Errorf("add protocol finalizers: %v", err)
	}

	if err = addlegacyEndpointContextSetter(stack, options); err != nil {
		return err
	}
	if err = addSetLoggerMiddleware(stack, options); err != nil {
		return err
	}
	if err = addClientRequestID(stack); err != nil {
		return err
	}
	if err = addComputeContentLength(stack); err != nil {
		return err
	}
	if err = addResolveEndpointMiddleware(stack, options); err != nil {
		return err
	}
	if err = addComputePayloadSHA256(stack); err != nil {
		return err
	}
	if err = addRetry(stack, options); err != nil {
		return err
	}
	if err = addRawResponseToMetadata(stack); err != nil {
		return err
	}
	if err = addRecordResponseTiming(stack); err != nil {
		return err
	}
	if err = addSpanRetryLoop(stack, options); err != nil {
		return err
	}
	if err = addClientUserAgent(stack, options); err != nil {
		return err
	}
	if err = smithyhttp.AddErrorCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = smithyhttp.AddCloseResponseBodyMiddleware(stack); err != nil {
		return err
	}
	if err = addSetLegacyContextSigningOptionsMiddleware(stack); err != nil {
		return err
	}
	if err = addTimeOffsetBuild(stack, c); err != nil {
		return err
	}
	if err = addUserAgentRetryMode(stack, options); err != nil {
		return err
	}
	if err = addOpAssociateVpcCidrBlockValidationMiddleware(stack); err != nil {
		return err
	}
	if err = stack.Initialize.Add(newServiceMetadataMiddleware_opAssociateVpcCidrBlock(options.Region), middleware.Before); err != nil {
		return err
	}
	if err = addRecursionDetection(stack); err != nil {
		return err
	}
	if err = addRequestIDRetrieverMiddleware(stack); err != nil {
		return err
	}
	if err = addResponseErrorMiddleware(stack); err != nil {
		return err
	}
	if err = addRequestResponseLogging(stack, options); err != nil {
		return err
	}
	if err = addDisableHTTPSMiddleware(stack, options); err != nil {
		return err
	}
	if err = addSpanInitializeStart(stack); err != nil {
		return err
	}
	if err = addSpanInitializeEnd(stack); err != nil {
		return err
	}
	if err = addSpanBuildRequestStart(stack); err != nil {
		return err
	}
	if err = addSpanBuildRequestEnd(stack); err != nil {
		return err
	}
	return nil
}

func newServiceMetadataMiddleware_opAssociateVpcCidrBlock(region string) *awsmiddleware.RegisterServiceMetadata {
	return &awsmiddleware.RegisterServiceMetadata{
		Region:        region,
		ServiceID:     ServiceID,
		OperationName: "AssociateVpcCidrBlock",
	}
}
